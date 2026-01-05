//
//  FloatingCommentInput.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import SwiftUI

struct FloatingCommentInput: View {
    let parentId: String
    let replyingTo: String?
    let onCommentPosted: () -> Void
    let onCancel: () -> Void
    
    @StateObject private var authService = AuthService.shared
    @State private var commentText: String = ""
    @State private var isPosting: Bool = false
    @State private var errorMessage: String?
    @State private var showAuthSheet: Bool = false
    @State private var isExpanded: Bool = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if let errorMessage = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                    Spacer()
                    Button("✕") {
                        self.errorMessage = nil
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
            }
            
            // Input flutuante
            HStack(alignment: isExpanded ? .top : .center, spacing: 12) {
                // Avatar do usuário
                if let user = authService.currentUser {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(user.username.prefix(1).uppercased()))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        )
                }
                
                // Campo de texto
                VStack(alignment: .leading, spacing: 4) {
                    // Tag de resposta (se houver)
                    if let replyingTo = replyingTo {
                        HStack(spacing: 4) {
                            Image(systemName: "arrowshape.turn.up.left.fill")
                                .font(.caption2)
                            Text("Respondendo @\(replyingTo)")
                                .font(.caption)
                            Spacer()
                            Button {
                                onCancel()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // TextField expansível
                    ZStack(alignment: .topLeading) {
                        if commentText.isEmpty {
                            Text(replyingTo != nil ? "Escreva sua resposta..." : "Adicionar comentário...")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        
                        TextEditor(text: $commentText)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 40, maxHeight: isExpanded ? 120 : 40)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Fechar") {
                                        isTextFieldFocused = false
                                    }
                                }
                            }
                            .onChange(of: commentText) { _, newValue in
                                let lineCount = newValue.components(separatedBy: "\n").count
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isExpanded = lineCount > 2 || newValue.count > 50
                                }
                            }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                }
                
                // Botão de enviar
                Button {
                    Task {
                        await postComment()
                    }
                } label: {
                    if isPosting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                VStack(spacing: 0) {
                    Divider()
                    Color(.systemBackground)
                }
            )
        }
        .onAppear {
            // Focar automaticamente se estiver respondendo
            if authService.isAuthenticated && replyingTo != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTextFieldFocused = true
                }
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthSheet {
                // Após login bem-sucedido
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func postComment() async {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Verificar se está autenticado antes de postar
        guard authService.isAuthenticated else {
            await MainActor.run {
                showAuthSheet = true
            }
            return
        }
        
        errorMessage = nil
        isPosting = true
        
        do {
            _ = try await authService.postComment(
                parentId: parentId,
                body: commentText.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            await MainActor.run {
                isPosting = false
                commentText = ""
                isExpanded = false
                isTextFieldFocused = false
                
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.success)
                
                print("✅ [FloatingCommentInput] Comentário postado com sucesso!")
            }
            
            // Aguardar um pouco para a API processar antes de recarregar
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
            
            await MainActor.run {
                onCommentPosted()
                print("🔄 [FloatingCommentInput] Recarregando comentários...")
            }
        } catch {
            await MainActor.run {
                isPosting = false
                errorMessage = error.localizedDescription
                
                // Feedback háptico de erro
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.error)
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        FloatingCommentInput(
            parentId: "test-id",
            replyingTo: nil,
            onCommentPosted: {},
            onCancel: {}
        )
    }
}

#Preview("Respondendo") {
    VStack {
        Spacer()
        FloatingCommentInput(
            parentId: "test-id",
            replyingTo: "luizmellodev",
            onCommentPosted: {},
            onCancel: {}
        )
    }
}

