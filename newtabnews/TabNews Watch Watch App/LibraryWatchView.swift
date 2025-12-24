//
//  LibraryWatchView.swift
//  TabNews Watch Watch App
//
//  Created by Luiz Mello on 20/11/25.
//

import SwiftUI

struct LibraryWatchView: View {
    @State private var likedPosts: [PostRequest] = []
    @State private var stats: (liked: Int, highlights: Int, notes: Int, folders: Int) = (0, 0, 0, 0)
    
    var body: some View {
        NavigationStack {
            List {
                // Estatísticas (clicáveis)
                Section {
                    // Curtidos
                    NavigationLink {
                        LikedPostsListWatch(posts: likedPosts)
                    } label: {
                        StatsRowWatch(icon: "heart.fill", label: "Curtidos", value: stats.liked, color: .red)
                    }
                    
                    // Destaques (não implementado)
                    StatsRowWatch(icon: "highlighter", label: "Destaques", value: stats.highlights, color: .yellow)
                    
                    // Anotações (não implementado)
                    StatsRowWatch(icon: "note.text", label: "Anotações", value: stats.notes, color: .blue)
                    
                    // Pastas (não implementado)
                    StatsRowWatch(icon: "folder.fill", label: "Pastas", value: stats.folders, color: .purple)
                } header: {
                    Text("Biblioteca")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } footer: {
                    if stats.liked == 0 {
                        Text("Curta posts no iPhone para vê-los aqui")
                            .font(.caption2)
                    }
                }
            }
            .navigationTitle("Biblioteca")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadLibrary()
                setupNotificationObserver()
            }
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [self] _ in
            loadLibrary()
        }
    }
    
    private func loadLibrary() {
        // Carregar posts curtidos
        if let data = UserDefaults.standard.data(forKey: "WatchLikedPosts") {
            print("⌚ [LibraryWatchView] Data encontrado para WatchLikedPosts: \(data.count) bytes")
            
            if let decoded = try? JSONDecoder().decode([PostRequest].self, from: data) {
                likedPosts = decoded
                print("⌚ [LibraryWatchView] ✅ \(likedPosts.count) posts curtidos carregados:")
                for (i, post) in likedPosts.enumerated() {
                    print("   \(i+1). \(post.title ?? "sem título")")
                }
            } else {
                likedPosts = []
                print("⌚ [LibraryWatchView] ❌ Falha ao decodificar posts curtidos")
            }
        } else {
            likedPosts = []
            print("⌚ [LibraryWatchView] ⚠️ Nenhum dado para WatchLikedPosts no UserDefaults")
        }
        
        // Carregar stats (usar contagem local de curtidos)
        stats = (
            liked: likedPosts.count,
            highlights: UserDefaults.standard.integer(forKey: "WatchHighlights"),
            notes: UserDefaults.standard.integer(forKey: "WatchNotes"),
            folders: UserDefaults.standard.integer(forKey: "WatchFolders")
        )
        
        print("⌚ [LibraryWatchView] Stats: ❤️\(stats.liked) 🖍\(stats.highlights) 📝\(stats.notes) 📁\(stats.folders)")
    }
}

// MARK: - Stats Row Component
struct StatsRowWatch: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(label)
                .font(.caption)
            
            Spacer()
            
            Text("\(value)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Lista de Posts Curtidos
struct LikedPostsListWatch: View {
    let posts: [PostRequest]
    
    var body: some View {
        List {
            if posts.isEmpty {
                Text("Nenhum post curtido")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ForEach(posts, id: \.id) { post in
                    NavigationLink {
                        PostDetailWatchView(post: post)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.title ?? "Sem título")
                                .font(.caption)
                                .lineLimit(3)
                            
                            HStack {
                                Text(post.ownerUsername ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                if let tabcoins = post.tabcoins {
                                    Spacer()
                                    Label("\(tabcoins)", systemImage: "star.fill")
                                        .font(.caption2)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Curtidos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LibraryWatchView()
}

