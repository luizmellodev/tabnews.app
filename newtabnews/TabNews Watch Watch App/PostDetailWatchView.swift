//
//  PostDetailWatchView.swift
//  TabNews Watch Watch App
//
//  Created by Luiz Mello on 20/11/25.
//

import SwiftUI

struct PostDetailWatchView: View {
    let post: PostRequest
    @StateObject private var ttsManager = TextToSpeechManager.shared
    @State private var selectedSpeed: Float = 1.0
    @State private var isLiked: Bool = false
    
    let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Título e Like
                HStack(alignment: .top) {
                    Text(post.title ?? "Sem título")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Button {
                        toggleLike()
                    } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(isLiked ? .pink : .gray)
                    }
                    .buttonStyle(.plain)
                }
                
                // Informações do post
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let owner = post.ownerUsername {
                            Text(owner)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let publishedAt = post.publishedAt {
                            Text(formatDate(publishedAt))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let tabcoins = post.tabcoins {
                        Label("\(tabcoins)", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Conteúdo do post
                if let body = post.body, !body.isEmpty {
                    Text(cleanMarkdown(body))
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Conteúdo não disponível")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                // CTA no final do post
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    Text("Gostou do que leu?")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("Lembre-se de abrir o site do TabNews e dar upvote no post para ajudar \(post.ownerUsername ?? "o autor")!")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("💡 Curta ou adicione o post a uma pasta no iPhone para ter salvo no app")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
                
                Divider()
                    .padding(.top, 8)
                
                // Controles de Áudio
                VStack(spacing: 12) {
                    Text("Ouvir Notícia")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Botão Play/Pause principal
                    Button {
                        if let body = post.body {
                            ttsManager.togglePlayPause(
                                text: body,
                                title: post.title
                            )
                        }
                    } label: {
                        Image(systemName: getPlayPauseIcon())
                            .font(.system(size: 40))
                            .foregroundColor(ttsManager.isPlaying ? .green : .blue)
                    }
                    .buttonStyle(.plain)
                    .disabled(post.body?.isEmpty ?? true)
                    
                    // Controles de velocidade
                    VStack(spacing: 6) {
                        Text("Velocidade")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 6) {
                            ForEach(speeds, id: \.self) { speed in
                                Button {
                                    selectedSpeed = speed
                                    ttsManager.setSpeed(speed)
                                } label: {
                                    Text(formatSpeed(speed))
                                        .font(.caption2)
                                        .fontWeight(selectedSpeed == speed ? .bold : .regular)
                                        .foregroundColor(selectedSpeed == speed ? .white : .secondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(selectedSpeed == speed ? Color.blue : Color.gray.opacity(0.3))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Botão Stop (só aparece se estiver tocando)
                    if ttsManager.isPlaying || ttsManager.isPaused {
                        Button {
                            ttsManager.stop()
                        } label: {
                            Label("Parar", systemImage: "stop.circle")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding()
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadLikeStatus()
        }
        .onDisappear {
            if ttsManager.isPlaying {
                ttsManager.stop()
            }
        }
    }
    
    // MARK: - Like Functions
    
    private func loadLikeStatus() {
        guard let postId = post.id else { return }
        
        if let likedData = UserDefaults.standard.data(forKey: "WatchLikedPosts"),
           let likedPosts = try? JSONDecoder().decode([PostRequest].self, from: likedData) {
            isLiked = likedPosts.contains(where: { $0.id == postId })
        }
    }
    
    private func toggleLike() {
        guard let postId = post.id else { return }
        
        WKInterfaceDevice.current().play(.click)
        
        var likedPosts: [PostRequest] = []
        if let likedData = UserDefaults.standard.data(forKey: "WatchLikedPosts"),
           let decoded = try? JSONDecoder().decode([PostRequest].self, from: likedData) {
            likedPosts = decoded
        }
        
        if isLiked {
            likedPosts.removeAll { $0.id == postId }
            isLiked = false
        } else {
            likedPosts.append(post)
            isLiked = true
        }
        
        if let encoded = try? JSONEncoder().encode(likedPosts) {
            UserDefaults.standard.set(encoded, forKey: "WatchLikedPosts")
        }
        
        WatchConnectivityManager.shared.syncLikedPostsToiPhone()
    }
    
    // MARK: - Helper Functions
    
    private func getPlayPauseIcon() -> String {
        if ttsManager.isPlaying {
            return "pause.circle.fill"
        } else if ttsManager.isPaused {
            return "play.circle.fill"
        } else {
            return "play.circle.fill"
        }
    }
    
    private func formatSpeed(_ speed: Float) -> String {
        if speed == 1.0 {
            return "1×"
        } else if speed == 0.5 {
            return "0.5×"
        } else {
            return String(format: "%.1f×", speed)
        }
    }
    
    private func cleanMarkdown(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
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
            return "\(days) dias atrás"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) horas atrás"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minutos atrás"
        } else {
            return "Agora"
        }
    }
}

