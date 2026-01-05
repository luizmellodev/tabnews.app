//
//  CommentComposeSheet.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import SwiftUI

struct CommentComposeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    let parentId: String
    let onCommentPosted: (() -> Void)?
    
    @State private var commentText: String = ""
    @State private var isPosting: Bool = false
    @State private var errorMessage: String?
    @State private var showAuthSheet: Bool = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let user = authService.currentUser {
                    userInfoView(user: user)
                }
                
                TextEditor(text: $commentText)
                    .focused($isTextFieldFocused)
                    .padding()
                    .frame(minHeight: 150)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Fechar") {
                                isTextFieldFocused = false
                            }
                        }
                    }
                    .overlay(
                        Group {
                            if commentText.isEmpty {
                                Text("Escreva seu comentário...")
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .allowsHitTesting(false)
                            }
                        }
                    )
                
                Divider()
                
                // Error Message
                if let errorMessage = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                }
                
                // Character Count
                HStack {
                    Text("\(commentText.count) caracteres")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationTitle("Novo Comentário")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await postComment()
                        }
                    } label: {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("Publicar")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
                }
            }
            .onAppear {
                // Se não estiver autenticado, mostrar auth sheet
                if !authService.isAuthenticated {
                    showAuthSheet = true
                } else {
                    isTextFieldFocused = true
                }
            }
            .sheet(isPresented: $showAuthSheet) {
                AuthSheet {
                    // Após login bem-sucedido, focar no campo de texto
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func userInfoView(user: User) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(user.username.prefix(1).uppercased()))
                        .font(.headline)
                        .foregroundStyle(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(user.username)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let tabcoins = user.tabcoins {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(tabcoins) tabcoins")
                            .font(.caption)
                    }
                    .foregroundStyle(.orange)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Actions
    
    private func postComment() async {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        errorMessage = nil
        isPosting = true
        
        do {
            _ = try await authService.postComment(
                parentId: parentId,
                body: commentText.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            await MainActor.run {
                isPosting = false
                isTextFieldFocused = false
                onCommentPosted?()
                
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
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
    CommentComposeSheet(parentId: "test-post-id", onCommentPosted: nil)
}

