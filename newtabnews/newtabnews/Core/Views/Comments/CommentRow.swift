//
//  CommentRow.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import SwiftUI

struct CommentRow: View {
    let comment: Comment
    let depth: Int
    var onReply: ((Comment) -> Void)?
    var onVote: ((Comment, String, @escaping (Bool) -> Void) -> Void)? // Callback com resultado
    
    @State private var isExpanded: Bool = true
    @State private var isVoting: Bool = false
    @State private var hasVoted: Bool = false // Previne múltiplos votos
    @State private var localTabcoins: Int? = nil // Para atualização otimista
    @State private var showConfetti: Bool = false // Para efeito de confete
    
    private let maxDepth = 5
    private let indentWidth: CGFloat = 16
    private let voteManager = VoteManager.shared
    
    init(comment: Comment, depth: Int, onReply: ((Comment) -> Void)? = nil, onVote: ((Comment, String, @escaping (Bool) -> Void) -> Void)? = nil) {
        self.comment = comment
        self.depth = depth
        self.onReply = onReply
        self.onVote = onVote
        
        // Verificar se já votou ao criar a view
        if let commentId = comment.id {
            _hasVoted = State(initialValue: VoteManager.shared.hasVoted(contentId: commentId))
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                // Comentário principal
                HStack(alignment: .top, spacing: 0) {
                    // Linha vertical de indentação
                    if depth > 0 {
                        ForEach(0..<min(depth, maxDepth), id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 2)
                                .padding(.leading, indentWidth - 2)
                        }
                    }
                    
                    // Conteúdo do comentário
                    VStack(alignment: .leading, spacing: 8) {
                    // Header (autor, data, tabcoins)
                    HStack(spacing: 8) {
                        // Avatar placeholder
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(String(comment.ownerUsername?.prefix(1).uppercased() ?? "?"))
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            )
                        
                        // Username
                        Text("@\(comment.ownerUsername ?? "Anônimo")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        // Data
                        Text(comment.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Tabcoins (usa localTabcoins se disponível, senão usa do comment)
                        let displayTabcoins = localTabcoins ?? comment.tabcoins ?? 0
                        if displayTabcoins != 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                Text("\(displayTabcoins)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(displayTabcoins > 0 ? .orange : .red)
                        }
                        
                        // Botão de expandir/colapsar se tiver respostas
                        if let children = comment.children, !children.isEmpty {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isExpanded.toggle()
                                }
                            } label: {
                                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Body do comentário
                    if let body = comment.body {
                        Text(body)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Footer (ações)
                    HStack(spacing: 16) {
                        // Botões de voto - minimalistas (desabilitados após votar)
                        if !hasVoted {
                            if !isVoting {
                                HStack(spacing: 12) {
                                // Upvote (Ache relevante)
                                Button {
                                    handleVote(transactionType: "credit")
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up")
                                            .font(.caption)
                                        Text("Relevante")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.green)
                                }
                                    
                                    // Downvote (Não achei relevante)
                                    Button {
                                        handleVote(transactionType: "debit")
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.down")
                                                .font(.caption)
                                            Text("Irrelevante")
                                                .font(.caption)
                                        }
                                        .foregroundStyle(.red)
                                    }
                                }
                            } else {
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                        } else {
                            // Mostrar que já votou
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                Text("Votado")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 12)
                        
                        // Botão de responder
                        Button {
                            onReply?(comment)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrowshape.turn.up.left")
                                    .font(.caption)
                                Text("Responder")
                                    .font(.caption)
                            }
                            .foregroundStyle(.blue)
                        }
                        
                        // Contador de respostas
                        if let children = comment.children, !children.isEmpty {
                            Text("• \(children.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.leading, depth > 0 ? 8 : 0)
                .padding(.vertical, 12)
            }
            
            // Respostas (recursivo)
            if isExpanded, let children = comment.children, !children.isEmpty {
                ForEach(children) { childComment in
                    CommentRow(
                        comment: childComment,
                        depth: min(depth + 1, maxDepth),
                        onReply: onReply,
                        onVote: onVote
                    )
                }
            }
        }
        
        // Confete overlay
        if showConfetti {
            GeometryReader { geometry in
                ParticleSystemView(
                    configuration: ParticleSystemConfiguration(
                        particleCount: 50,
                        shapes: [.confetti],
                        colors: [.red, .blue, .green, .yellow, .purple, .orange, .pink],
                        minSize: 6,
                        maxSize: 12,
                        minVelocity: 200,
                        maxVelocity: 400,
                        gravity: 600,
                        lifetime: 2.0,
                        emissionAngle: -90...90
                    ),
                    origin: CGPoint(x: geometry.size.width / 2, y: 50)
                )
                .allowsHitTesting(false)
            }
        }
    }
}
    
    // MARK: - Actions
    
    private func handleVote(transactionType: String) {
        guard let commentId = comment.id else { return }
        guard !hasVoted else { return } // Previne múltiplos votos
        
        isVoting = true
        
        // Atualização otimista
        let currentTabcoins = localTabcoins ?? comment.tabcoins ?? 0
        localTabcoins = transactionType == "credit" ? currentTabcoins + 1 : currentTabcoins - 1
        
        // Chamar callback com uma completion para saber se teve sucesso
        onVote?(comment, transactionType) { success in
            isVoting = false
            
            if success {
                hasVoted = true // Desabilita botões permanentemente
                
                // Marcar como votado persistentemente
                if let commentId = comment.id {
                    voteManager.markAsVoted(contentId: commentId)
                }
                
                // 🎉 Disparar confete se for upvote e teve sucesso!
                if transactionType == "credit" {
                    print("🎊 [CommentRow] Disparando confete!")
                    showConfetti = true
                    
                    // Desligar confete após 2 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print("🎊 [CommentRow] Desligando confete")
                        showConfetti = false
                    }
                }
            } else {
                // Reverter atualização otimista se falhou
                localTabcoins = comment.tabcoins
            }
        }
    }
}

#Preview("Comentário Simples") {
    ScrollView {
        VStack(spacing: 0) {
            CommentRow(
                comment: Comment(
                    id: "1",
                    ownerUsername: "luizmellodev",
                    ownerID: "user-123",
                    slug: "comentario-teste",
                    title: nil,
                    body: "Este é um comentário de exemplo! 🚀\n\nPodemos usar **markdown** e `código`.",
                    status: "published",
                    sourceURL: nil,
                    createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                    updatedAt: nil,
                    publishedAt: nil,
                    deletedAt: nil,
                    tabcoins: 5,
                    tabcoinsCredit: 5,
                    tabcoinsDebit: 0,
                    childrenDeepCount: 0,
                    parentID: "post-123",
                    children: nil
                ),
                depth: 0,
                onReply: { _ in }
            )
            
            Divider()
        }
    }
}

#Preview("Comentário com Respostas") {
    ScrollView {
        VStack(spacing: 0) {
            CommentRow(
                comment: Comment.mockComment,
                depth: 0,
                onReply: { _ in }
            )
            Divider()
        }
    }
}

