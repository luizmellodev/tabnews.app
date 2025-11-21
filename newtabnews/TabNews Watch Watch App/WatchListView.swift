//
//  WatchListView.swift
//  TabNews Watch Watch App
//
//  Created by Luiz Mello on 20/11/25.
//  VERSÃO SIMPLIFICADA
//

import SwiftUI

struct WatchListView: View {
    @State private var posts: [PostRequest] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if posts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "newspaper")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Nenhum post disponível")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Abra o app no iPhone")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(posts, id: \.id) { post in
                            NavigationLink {
                                PostDetailWatchView(post: post)
                            } label: {
                                PostRowWatch(post: post)
                            }
                        }
                    }
                    .listStyle(.carousel)
                }
            }
            .navigationTitle("TabNews")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // Pull to refresh
                await refreshPosts()
            }
        }
        .onAppear {
            loadPosts()
        }
    }
    
    private func loadPosts() {
        // Ler posts salvos localmente
        if let data = UserDefaults.standard.data(forKey: "WatchPosts"),
           let decoded = try? JSONDecoder().decode([PostRequest].self, from: data) {
            posts = decoded
            print("⌚ \(posts.count) posts")
        } else {
            posts = []
            print("⌚ Sem posts - Sincronize no iPhone")
        }
    }
    
    private func refreshPosts() async {
        // Pequeno delay para feedback visual
        try? await Task.sleep(nanoseconds: 300_000_000)
        loadPosts()
    }
}

// MARK: - Post Row Component
struct PostRowWatch: View {
    let post: PostRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Título
            Text(post.title ?? "Sem título")
                .font(.headline)
                .lineLimit(3)
            
            // Info
            HStack(spacing: 8) {
                // Autor
                Text(post.ownerUsername ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Tabcoins
                if let tabcoins = post.tabcoins {
                    Label("\(tabcoins)", systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
            
            // Data
            if let publishedAt = post.publishedAt {
                Text(formatDate(publishedAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return "Data desconhecida"
        }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days)d atrás"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h atrás"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)min atrás"
        } else {
            return "Agora"
        }
    }
}

#Preview {
    WatchListView()
}

