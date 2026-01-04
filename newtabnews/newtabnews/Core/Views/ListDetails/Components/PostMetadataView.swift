//
//  PostMetadataView.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct PostMetadataView: View {
    let post: PostRequest
    
    @State private var isVoting: Bool = false
    @State private var hasVoted: Bool = false
    @State private var localTabcoins: Int? = nil
    @State private var showConfetti: Bool = false
    @State private var showAuthSheet: Bool = false
    
    private let authService = AuthService.shared
    private let voteManager = VoteManager.shared
    
    init(post: PostRequest) {
        self.post = post
        
        // Verificar se já votou
        if let postId = post.id {
            _hasVoted = State(initialValue: VoteManager.shared.hasVoted(contentId: postId))
        }
    }
    
    var displayTabcoins: Int {
        localTabcoins ?? post.tabcoins ?? 0
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                // Primeira linha: Autor e Data
                HStack {
                    Text(post.ownerUsername ?? "luizmellodev")
                        .font(.footnote)
                    Spacer()
                    Text(getFormattedDate(value: post.createdAt ?? "sábado-feira, 31 fevereiro"))
                        .font(.footnote)
                        .italic()
                }
                .foregroundColor(.gray)
                
                // Segunda linha: Tabcoins e botões de voto (minimalistas)
                HStack(spacing: 12) {
                    // Indicador de tabcoins
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(displayTabcoins)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(displayTabcoins > 0 ? .orange : .secondary)
                    
                    // Botões de voto (super discretos)
                    if !hasVoted {
                        if !isVoting {
                            HStack(spacing: 8) {
                                // Upvote
                                Button {
                                    handleVote(transactionType: "credit")
                                } label: {
                                    Image(systemName: "arrow.up")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                // Downvote
                                Button {
                                    handleVote(transactionType: "debit")
                                } label: {
                                    Image(systemName: "arrow.down")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            ProgressView()
                                .controlSize(.mini)
                        }
                    } else {
                        // Já votou
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .foregroundColor(.gray)
            }
            
            // Confete overlay
            if showConfetti {
                GeometryReader { geometry in
                    ParticleSystemView(
                        configuration: ParticleSystemConfiguration(
                            particleCount: 100,
                            shapes: [.confetti],
                            colors: [.red, .blue, .green, .yellow, .purple, .orange, .pink],
                            minSize: 6,
                            maxSize: 12,
                            minVelocity: 200,
                            maxVelocity: 400,
                            gravity: 600,
                            lifetime: 2.5,
                            emissionAngle: -90...90
                        ),
                        origin: CGPoint(x: 80, y: geometry.size.height - 10)
                    )
                    .allowsHitTesting(false)
                }
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthSheet()
        }
    }
    
    // MARK: - Actions
    
    private func handleVote(transactionType: String) {
        guard let username = post.ownerUsername,
              let slug = post.slug else {
            print("❌ [PostMetadataView] Post sem username ou slug")
            return
        }
        
        guard !hasVoted else { return }
        
        // Verificar autenticação
        guard authService.isAuthenticated else {
            showAuthSheet = true
            return
        }
        
        isVoting = true
        
        // Atualização otimista
        let currentTabcoins = localTabcoins ?? post.tabcoins ?? 0
        localTabcoins = transactionType == "credit" ? currentTabcoins + 1 : currentTabcoins - 1
        
        Task {
            do {
                try await authService.voteOnContent(
                    username: username,
                    slug: slug,
                    transactionType: transactionType
                )
                print("✅ [PostMetadataView] Voto registrado com sucesso")
                
                await MainActor.run {
                    isVoting = false
                    hasVoted = true
                    
                    // Marcar como votado persistentemente
                    if let postId = post.id {
                        voteManager.markAsVoted(contentId: postId)
                    }
                    
                    // Disparar confete se for upvote
                    if transactionType == "credit" {
                        print("🎊 [PostMetadataView] Disparando confete!")
                        showConfetti = true
                        
                        // Desligar após 2.5 segundos
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            showConfetti = false
                        }
                    }
                }
            } catch {
                print("❌ [PostMetadataView] Erro ao votar: \(error)")
                
                await MainActor.run {
                    isVoting = false
                    // Reverter atualização otimista
                    localTabcoins = post.tabcoins
                }
            }
        }
    }
}
