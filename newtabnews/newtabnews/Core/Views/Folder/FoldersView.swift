//
//  FoldersView.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/11/25.
//

import SwiftUI
import SwiftData

struct FoldersView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MainViewModel.self) private var viewModel
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    @Query private var highlights: [Highlight]
    @Query private var notes: [Note]
    
    // Usar String IDs para pastas especiais (mais seguro que UUID)
    private enum SpecialFolder: String {
        case liked = "special_liked"
        case highlights = "special_highlights"
        case notes = "special_notes"
    }
    
    @State private var expandedFolders: Set<String> = [] // String ao invés de UUID
    @State private var showingAddFolder = false
    @State private var selectedPost: PostRequest?
    @State private var selectedHighlights: [Highlight] = []
    @State private var isEditMode = false
    @State private var selectedFolderIds: Set<UUID> = []
    @StateObject private var usageTracker = AppUsageTracker.shared
    @State private var showingGame = false
    
    var body: some View {
        NavigationStack {
            Group {
            if folders.isEmpty && highlights.isEmpty && notes.isEmpty && uniqueLikedPosts.isEmpty {
                emptyState
            } else {
                    List {
                        // Pasta Especial: Curtidos
                        if !uniqueLikedPosts.isEmpty {
                            Section {
                                SpecialFolderRow(
                                    name: "Curtidos",
                                    icon: "heart.fill",
                                    color: "#FF3B30",
                                    count: uniqueLikedPosts.count,
                                    isExpanded: expandedFolders.contains(SpecialFolder.liked.rawValue),
                                    onToggle: {
                                        toggleSpecialFolder(.liked)
                                    }
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        clearAllLiked()
                                    } label: {
                                        Label("Remover Todos os Curtidos", systemImage: "heart.slash.fill")
                                    }
                                    .disabled(uniqueLikedPosts.isEmpty)
                                }
                                
                                if expandedFolders.contains(SpecialFolder.liked.rawValue) {
                                    ForEach(uniqueLikedPosts) { post in
                                        PostFileRow(
                                            post: post,
                                            onTap: {
                                                selectedPost = post
                                            }
                                        )
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                viewModel.removeContentList(content: post)
                                            } label: {
                                                Label("Remover dos Curtidos", systemImage: "heart.slash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Pasta Especial: Destaques
                        if !highlights.isEmpty {
                            Section {
                                SpecialFolderRow(
                                    name: "Destaques",
                                    icon: "highlighter",
                                    color: "#FFFF00",
                                    count: highlights.count,
                                    isExpanded: expandedFolders.contains(SpecialFolder.highlights.rawValue),
                                    onToggle: {
                                        toggleSpecialFolder(.highlights)
                                    }
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        clearAllHighlights()
                                    } label: {
                                        Label("Excluir Todos os Destaques", systemImage: "trash")
                                    }
                                    .disabled(highlights.isEmpty)
                                }
                                
                                if expandedFolders.contains(SpecialFolder.highlights.rawValue) {
                                    ForEach(groupedHighlights, id: \.key) { postId, postHighlights in
                                        if let post = getPost(byId: postId) {
                                            PostFileRow(
                                                post: post,
                                                hasHighlights: true,
                                                highlightPreview: postHighlights.first?.highlightedText,
                                                onTap: {
                                                    selectedPost = post
                                                    selectedHighlights = postHighlights
                                                }
                                            )
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    deleteHighlightsForPost(postId: postId)
                                                } label: {
                                                    Label("Excluir Todos os Destaques", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Pasta Especial: Anotações
                        if !notes.isEmpty {
                            Section {
                                SpecialFolderRow(
                                    name: "Anotações",
                                    icon: "note.text",
                                    color: "#FF9500",
                                    count: notes.count,
                                    isExpanded: expandedFolders.contains(SpecialFolder.notes.rawValue),
                                    onToggle: {
                                        toggleSpecialFolder(.notes)
                                    }
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        clearAllNotes()
                                    } label: {
                                        Label("Excluir Todas as Anotações", systemImage: "trash")
                                    }
                                    .disabled(notes.isEmpty)
                                }
                                
                                if expandedFolders.contains(SpecialFolder.notes.rawValue) {
                                    ForEach(notes) { note in
                                        if let post = getPost(byId: note.postId) {
                                            PostFileRow(
                                                post: post,
                                                hasNote: true,
                                                onTap: {
                                                    selectedPost = post
                                                }
                                            )
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    deleteNotesForPost(postId: note.postId)
                                                } label: {
                                                    Label("Excluir Todas as Anotações", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Pasta Especial: Descanse (Easter Egg após 30 min)
                        if usageTracker.shouldShowRestFolder {
                            Section {
                                Button(action: {
                                    showingGame = true
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 12)
                                        
                                        Image(systemName: "moon.stars.fill")
                                            .foregroundColor(Color(hex: "#9B59B6"))
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Descanse")
                                                .foregroundColor(.primary)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            
                                            Text("Você merece uma pausa! 🎮")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("1")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.secondary.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Pastas do Usuário
                        if !folders.isEmpty {
                            Section("Minhas Pastas") {
                                ForEach(folders) { folder in
                                    UserFolderRow(
                                        name: folder.name,
                                        icon: folder.icon,
                                        color: folder.colorHex,
                                        count: folder.postCount,
                                        isExpanded: expandedFolders.contains(folder.id.uuidString),
                                        isEditMode: isEditMode,
                                        isSelected: selectedFolderIds.contains(folder.id),
                                        onToggle: {
                                            if isEditMode {
                                                toggleSelection(folder.id)
                                            } else {
                                                toggleUserFolder(folder.id)
                                            }
                                        }
                                    )
                                    .contextMenu {
                                        Button {
                                            clearFolder(folder)
                                        } label: {
                                            Label("Limpar Tudo", systemImage: "trash.slash")
                                        }
                                        .disabled(folder.postIds.isEmpty)
                                        
                                        Divider()
                                        
                                        Button(role: .destructive) {
                                            deleteFolder(folder)
                                        } label: {
                                            Label("Excluir Pasta", systemImage: "trash")
                                        }
                                    }
                                    
                                    if expandedFolders.contains(folder.id.uuidString) {
                                        ForEach(getPostsInFolder(folder)) { post in
                                            PostFileRow(
                                                post: post,
                                                onTap: {
                                                    selectedPost = post
                                                }
                                            )
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    removePostFromFolder(post, folder: folder)
                                                } label: {
                                                    Label("Remover da Pasta", systemImage: "folder.badge.minus")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Biblioteca")
            .navigationBarTitleDisplayMode(.large)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                AddFolderSheet()
            }
            .sheet(item: $selectedPost) { post in
                PostWithHighlightsView(
                    post: post,
                    highlights: selectedHighlights
                )
                .onDisappear {
                    selectedHighlights = []
                }
            }
            .onAppear {
                viewModel.getLikedContent()
            }
            .fullScreenCover(isPresented: $showingGame) {
                FlappyBirdGame(showCloseButton: true)
            }
            .overlay(alignment: .bottomTrailing) {
                if !folders.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedFolderIds.removeAll()
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isEditMode ? "checkmark" : "pencil")
                                .font(.headline)
                            Text(isEditMode ? "Concluir" : "Editar")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background {
                            Capsule()
                                .fill(isEditMode ? Color.green : Color.blue)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    .accessibilityLabel(isEditMode ? "Concluir edição" : "Entrar no modo de edição")
                }
            }
            .overlay(alignment: .bottom) {
                if isEditMode && !selectedFolderIds.isEmpty {
                    HStack(spacing: 20) {
                        Button {
                            deleteSelectedFolders()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.title3)
                                Text("Excluir (\(selectedFolderIds.count))")
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        Button {
                            clearSelectedFolders()
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "trash.slash")
                                    .font(.title3)
                                Text("Limpar (\(selectedFolderIds.count))")
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea(edges: .bottom)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 70))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("Sua Biblioteca")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Curta posts, crie destaques ou organize em pastas")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                showingAddFolder = true
            } label: {
                Label("Criar Pasta", systemImage: "folder.badge.plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
            
            // Easter Egg: Jogar enquanto não tem nada (só aparece após 10 min de uso)
            if usageTracker.shouldShowGameButton {
                NavigationLink {
                    FlappyBirdGame()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.caption)
                        Text("Jogar enquanto isso")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var groupedHighlights: [(key: String, value: [Highlight])] {
        Dictionary(grouping: highlights, by: { $0.postId })
            .sorted { $0.value.first?.createdAt ?? Date() > $1.value.first?.createdAt ?? Date() }
    }
    
    private var uniqueLikedPosts: [PostRequest] {
        // Remover duplicatas baseado no ID
        var seen: Set<String> = []
        return viewModel.likedList.filter { post in
            guard let id = post.id else { return false }
            if seen.contains(id) {
                return false
            }
            seen.insert(id)
            return true
        }
    }
    
    private func toggleSpecialFolder(_ folder: SpecialFolder) {
        withAnimation {
            if expandedFolders.contains(folder.rawValue) {
                expandedFolders.remove(folder.rawValue)
            } else {
                expandedFolders.insert(folder.rawValue)
            }
        }
    }
    
    private func toggleUserFolder(_ id: UUID) {
        withAnimation {
            let idString = id.uuidString
            if expandedFolders.contains(idString) {
                expandedFolders.remove(idString)
            } else {
                expandedFolders.insert(idString)
            }
        }
    }
    
    private func getPost(byId id: String) -> PostRequest? {
        viewModel.content.first { $0.id == id }
    }
    
    private func getPostsInFolder(_ folder: Folder) -> [PostRequest] {
        viewModel.content.filter { post in
            guard let postId = post.id else { return false }
            return folder.postIds.contains(postId)
        }
    }
    
    private func deleteFolder(_ folder: Folder) {
        withAnimation {
            modelContext.delete(folder)
        }
    }
    
    private func clearFolder(_ folder: Folder) {
        withAnimation {
            folder.postIds.removeAll()
        }
    }
    
    private func removePostFromFolder(_ post: PostRequest, folder: Folder) {
        guard let postId = post.id else { return }
        withAnimation {
            folder.postIds.removeAll { $0 == postId }
        }
    }
    
    private func deleteHighlightsForPost(postId: String) {
        withAnimation {
            let highlightsToDelete = highlights.filter { $0.postId == postId }
            for highlight in highlightsToDelete {
                modelContext.delete(highlight)
            }
        }
    }
    
    private func deleteNotesForPost(postId: String) {
        withAnimation {
            let notesToDelete = notes.filter { $0.postId == postId }
            for note in notesToDelete {
                modelContext.delete(note)
            }
        }
    }
    
    private func clearAllLiked() {
        withAnimation {
            viewModel.clearAllLikedContent()
        }
    }
    
    private func clearAllHighlights() {
        withAnimation {
            for highlight in highlights {
                modelContext.delete(highlight)
            }
        }
    }
    
    private func clearAllNotes() {
        withAnimation {
            for note in notes {
                modelContext.delete(note)
            }
        }
    }
    
    private func toggleSelection(_ folderId: UUID) {
        if selectedFolderIds.contains(folderId) {
            selectedFolderIds.remove(folderId)
        } else {
            selectedFolderIds.insert(folderId)
        }
    }
    
    private func deleteSelectedFolders() {
        withAnimation {
            for folderId in selectedFolderIds {
                if let folder = folders.first(where: { $0.id == folderId }) {
                    modelContext.delete(folder)
                }
            }
            selectedFolderIds.removeAll()
            isEditMode = false
        }
    }
    
    private func clearSelectedFolders() {
        withAnimation {
            for folderId in selectedFolderIds {
                if let folder = folders.first(where: { $0.id == folderId }) {
                    folder.postIds.removeAll()
                }
            }
            selectedFolderIds.removeAll()
        }
    }
}

// Componente de Linha de Pasta Especial
struct SpecialFolderRow: View {
    let name: String
    let icon: String
    let color: String
    let count: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 12)
                    .animation(.spring(response: 0.3), value: isExpanded)
                
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                    .font(.title3)
                
                Text(name)
                    .foregroundColor(.primary)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Componente de Linha de Pasta do Usuário
struct UserFolderRow: View {
    let name: String
    let icon: String
    let color: String
    let count: Int
    let isExpanded: Bool
    var isEditMode: Bool = false
    var isSelected: Bool = false
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .animation(.spring(response: 0.3), value: isSelected)
                } else {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 12)
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
                
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                    .font(.title3)
                
                Text(name)
                    .foregroundColor(.primary)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                if !isEditMode {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Componente de Linha de Post (Arquivo)
struct PostFileRow: View {
    let post: PostRequest
    var hasHighlights: Bool = false
    var hasNote: Bool = false
    var highlightPreview: String? = nil
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Spacer()
                    .frame(width: 12)
                
                Image(systemName: "doc.text")
                    .foregroundStyle(.secondary)
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(post.title ?? "Sem título")
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    // Mostrar preview do highlight se existir
                    if let preview = highlightPreview, hasHighlights {
                        Text("\(preview)")
                            .font(.caption)
                            .italic()
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 6) {
                        if hasHighlights {
                            HStack(spacing: 2) {
                                Image(systemName: "highlighter")
                                    .font(.caption2)
                                Text("Destacado")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.yellow)
                        }
                        if hasNote {
                            HStack(spacing: 2) {
                                Image(systemName: "note.text")
                                    .font(.caption2)
                                Text("Anotação")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.orange)
                        }
                        
                        if hasHighlights || hasNote {
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(post.ownerUsername ?? "")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.leading, 28)
    }
}

// Extensão para converter hex em Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
