//
//  LoginSheet.swift
//  newtabnews
//
//  Created by Luiz Mello on 07/01/26.
//

import SwiftUI

struct LoginSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var onSuccess: (() -> Void)?
    var onSignupTapped: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(MinimalTextFieldStyle())
                        
                        SecureField("Senha", text: $password)
                            .textContentType(.password)
                            .textFieldStyle(MinimalTextFieldStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 20)
                    }
                    
                    Button {
                        Task {
                            await handleLogin()
                        }
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(Color("Background"))
                            } else {
                                Text("Entrar")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(isFormValid ? Color.primary : Color.gray)
                    .foregroundStyle(Color("Background"))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .disabled(!isFormValid || isLoading)
                    
                    HStack(spacing: 4) {
                        Text("Não tem uma conta?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            dismiss()
                            onSignupTapped?()
                        } label: {
                            Text("Criar conta")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 20)
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
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.primary.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                )
            
            Text("Bem-vindo")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Entre para comentar e interagir")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func handleLogin() async {
        print("🚀 [LoginSheet] Iniciando login")
        
        errorMessage = nil
        isLoading = true
        
        do {
            print("📧 [LoginSheet] Email: \(email)")
            try await authService.login(email: email, password: password)
            
            print("✅ [LoginSheet] Login bem-sucedido!")
            
            await MainActor.run {
                isLoading = false
                onSuccess?()
                dismiss()
            }
        } catch {
            print("❌ [LoginSheet] Erro: \(error.localizedDescription)")
            
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    LoginSheet()
}

