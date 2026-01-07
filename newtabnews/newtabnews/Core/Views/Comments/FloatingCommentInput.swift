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
    @State private var showLoginSheet: Bool = false
    @State private var showSignupSheet: Bool = false
    @State private var isExpanded: Bool = false
    @State private var showMarkdownToolbar: Bool = false
    
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
            
            if let replyingTo = replyingTo {
                HStack(spacing: 6) {
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
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.05))
            }
            
            if showMarkdownToolbar {
                markdownToolbar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            HStack(alignment: .center, spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMarkdownToolbar.toggle()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(showMarkdownToolbar ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                
                HStack(alignment: .center, spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        if commentText.isEmpty {
                            Text(replyingTo != nil ? "Resposta..." : "Comentário...")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        
                        TextEditor(text: $commentText)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 36, maxHeight: isExpanded ? 120 : 36)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .padding(.trailing, 36)
                            .onChange(of: commentText) { _, newValue in
                                let lineCount = newValue.components(separatedBy: "\n").count
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isExpanded = lineCount > 1 || newValue.count > 40
                                }
                            }
                            .onChange(of: isTextFieldFocused) { _, newValue in
                                if !newValue {
                                    withAnimation {
                                        showMarkdownToolbar = false
                                    }
                                }
                            }
                        
                        HStack {
                            Spacer()
                            Button {
                                Task {
                                    await postComment()
                                }
                            } label: {
                                if isPosting {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(width: 28, height: 28)
                                } else {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .blue)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
                            .padding(.trailing, 4)
                            .padding(.top, 4)
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .background(
            VStack(spacing: 0) {
                Divider()
                Color(.systemBackground)
            }
        )
        .onAppear {
            if authService.isAuthenticated && replyingTo != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTextFieldFocused = true
                }
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginSheet(
                onSuccess: {
                    isTextFieldFocused = true
                },
                onSignupTapped: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showSignupSheet = true
                    }
                }
            )
        }
        .sheet(isPresented: $showSignupSheet) {
            SignupWebView()
        }
    }
    
    // MARK: - Subviews
    
    private var markdownToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CompactMarkdownButton(icon: "bold") {
                    insertMarkdown(prefix: "**", suffix: "**", placeholder: "texto")
                }

                CompactMarkdownButton(icon: "italic") {
                    insertMarkdown(prefix: "*", suffix: "*", placeholder: "texto")
                }

                CompactMarkdownButton(icon: "link") {
                    insertMarkdown(prefix: "[", suffix: "](url)", placeholder: "texto")
                }

                CompactMarkdownButton(icon: "chevron.left.forwardslash.chevron.right") {
                    insertMarkdown(prefix: "`", suffix: "`", placeholder: "código")
                }

                CompactMarkdownButton(icon: "text.quote") {
                    insertMarkdown(prefix: "> ", suffix: "", placeholder: "citação")
                }

                CompactMarkdownButton(icon: "list.bullet") {
                    insertMarkdown(prefix: "- ", suffix: "", placeholder: "item")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4).opacity(0.5), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
    
    // MARK: - Actions
    
    private func insertMarkdown(prefix: String, suffix: String, placeholder: String) {
        let newText = prefix + placeholder + suffix
        
        if commentText.isEmpty {
            commentText = newText
        } else {
            commentText += "\n" + newText
        }
        
        isTextFieldFocused = true
    }
    
    private func postComment() async {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        guard authService.isAuthenticated else {
            await MainActor.run {
                showLoginSheet = true
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
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            await MainActor.run {
                onCommentPosted()
                print("🔄 [FloatingCommentInput] Recarregando comentários...")
            }
        } catch {
            await MainActor.run {
                isPosting = false
                errorMessage = error.localizedDescription
                
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Compact Markdown Button

struct CompactMarkdownButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color(.systemGray5).opacity(0.3))
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray4).opacity(0.2), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
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
