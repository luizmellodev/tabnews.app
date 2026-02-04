//
//  LoginWebView.swift
//  newtabnews
//
//  Created by Luiz Mello on 21/01/26.
//

import SwiftUI
import WebKit

struct LoginWebView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var isProcessingLogin = false
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                WebViewContainer(
                    url: URL(string: "https://www.tabnews.com.br/login")!,
                    onLoginDetected: { sessionToken in
                        handleLoginDetected(sessionToken: sessionToken)
                    }
                )
                
                // Overlay de sucesso
                if showSuccessMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                        
                        Text("Login realizado!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Fechando...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.2), radius: 20)
                    )
                }
            }
            .navigationTitle("Entrar")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Fechar") {
                            dismiss()
                        }
                        .foregroundStyle(.primary)
                    }
                }
        }
    }
    
    // MARK: - Actions
    
    private func handleLoginDetected(sessionToken: String) {
        // Evitar processamento duplicado
        guard !isProcessingLogin else {
            print("⚠️ [LoginWebView] Já está processando login, ignorando...")
            return
        }
        
        isProcessingLogin = true
        
        // Verificar se já temos esse token salvo
        if let existingToken = KeychainManager.shared.getSessionToken(),
           existingToken == sessionToken {
            print("⚠️ [LoginWebView] Token já existe no Keychain, forçando refresh do usuário...")
            
            // Token já existe, mas pode não ter usuário salvo
            // Forçar refresh para garantir que o estado está correto
            Task {
                do {
                    try await authService.refreshUserData()
                    
                    await MainActor.run {
                        print("✅ [LoginWebView] Usuário atualizado com sucesso!")
                        showSuccessMessage = true
                        
                        // Fechar após 1.5 segundos
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                } catch {
                    await MainActor.run {
                        print("❌ [LoginWebView] Erro ao atualizar usuário: \(error)")
                        showSuccessMessage = false
                    }
                }
            }
            return
        }
        
        print("🔐 [LoginWebView] Processando login com token detectado")
        
        Task {
            do {
                // Salvar o token
                _ = KeychainManager.shared.saveSessionToken(sessionToken)
                
                // Buscar dados do usuário
                try await authService.refreshUserData()
                
                await MainActor.run {
                    print("✅ [LoginWebView] Login bem-sucedido!")
                    showSuccessMessage = true
                    
                    // Fechar após 1.5 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ [LoginWebView] Erro ao processar login: \(error)")
                    // NÃO resetar isProcessingLogin para evitar loop infinito
                    // O usuário pode fechar e tentar novamente manualmente
                    showSuccessMessage = false
                }
            }
        }
    }
}

#Preview {
    LoginWebView()
}
