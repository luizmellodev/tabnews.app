//
//  DailyDigestView.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/02/26.
//

import SwiftUI

struct DailyDigestView: View {
    @StateObject private var digestManager = DailyDigestManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPost: PostRequest?
    @State private var isLoadingPost = false
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    
    private let contentService = ContentService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if digestManager.isLoading && digestManager.todayDigest == nil {
                    loadingView
                } else if let digest = digestManager.todayDigest, !digest.items.isEmpty {
                    digestContent(digest)
                        .opacity(digestManager.isLoading ? 0.5 : 1.0)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Daily Dev Briefing")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await digestManager.generateTodayDigest()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(digestManager.isLoading ? .secondary : .blue)
                    }
                    .disabled(digestManager.isLoading)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .background {
                ZStack {
                    Color("Background")
                        .ignoresSafeArea()
                    Image("ruido")
                        .resizable()
                        .scaledToFill()
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                }
            }
            .sheet(item: $selectedPost) { post in
                ListDetailView(
                    isViewInApp: $isViewInApp,
                    currentTheme: $currentTheme,
                    post: post
                )
            }
            .task {
                await digestManager.generateTodayDigest()
            }
            .overlay(alignment: .top) {
                if digestManager.isLoading && digestManager.todayDigest != nil {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Atualizando...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .overlay {
                if isLoadingPost {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.3)
                                .tint(.white)
                            Text("Carregando post...")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                }
            }
            .animation(.spring(), value: digestManager.isLoading)
        }
    }
    
    // MARK: - Post Loading
    
    private func loadFullPostAndNavigate(_ post: PostRequest) async {
        guard let username = post.ownerUsername, let slug = post.slug else { return }
        
        await MainActor.run {
            isLoadingPost = true
        }
        
        do {
            let fullPost = try await contentService.getPost(user: username, slug: slug)
            
            await MainActor.run {
                self.selectedPost = fullPost
                self.isLoadingPost = false
            }
        } catch {
            await MainActor.run {
                self.isLoadingPost = false
                print("❌ Erro ao carregar post completo: \(error)")
            }
        }
    }
    
    // MARK: - Content Views
    
    private func digestContent(_ digest: DailyDigest) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView(digest)
                
                VStack(spacing: 16) {
                    ForEach(Array(digest.items.enumerated()), id: \.element.id) { index, item in
                        DigestItemCard(
                            item: item,
                            rank: index + 1,
                            onTap: {
                                Task {
                                    await loadFullPostAndNavigate(item.post)
                                }
                            }
                        )
                        .disabled(isLoadingPost)
                    }
                }
            }
            .padding()
        }
    }
    
    private func headerView(_ digest: DailyDigest) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 35))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 6) {
                Text(digest.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Top \(digest.items.count) discussões de hoje")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Preparando seu briefing...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Carregando posts...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await digestManager.generateTodayDigest()
        }
    }
}

// MARK: - Digest Item Card

struct DigestItemCard: View {
    let item: DailyDigestItem
    let rank: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(rankColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Text("\(rank)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(rankColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.post.title ?? "Sem título")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 12) {
                        Label("\(item.post.tabcoins ?? 0)", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        
                        if let comments = item.post.childrenDeepCount, comments > 0 {
                            Label("\(comments)", systemImage: "bubble.left.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        
                        Spacer()
                        
                        if let username = item.post.ownerUsername {
                            Text("@\(username)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(rankColor.opacity(0.2), lineWidth: rank <= 3 ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

// MARK: - Banner

struct DailyDigestBanner: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 0) {
                        Text("Seu daily dev briefing está pronto")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                    
                    Text("Veja os destaques de hoje")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: .blue.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DailyDigestView(isViewInApp: .constant(true), currentTheme: .constant(.light))
}

#Preview("Banner") {
    VStack {
        DailyDigestBanner(onTap: {})
            .padding()
        Spacer()
    }
}
