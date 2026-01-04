//
//  AuthSheet.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import SwiftUI

enum AuthMode {
    case login
    case signup
}

struct AuthSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var mode: AuthMode = .login
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccess: Bool = false
    
    var onSuccess: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo/Header - minimalista
                    headerView
                    
                    // Segmented Control - minimalista
                    Picker("Modo", selection: $mode) {
                        Text("Entrar").tag(AuthMode.login)
                        Text("Cadastrar").tag(AuthMode.signup)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    
                    // Form - minimalista
                    VStack(spacing: 12) {
                        if mode == .signup {
                            TextField("Nome de usuário", text: $username)
                                .textContentType(.username)
                                .autocapitalization(.none)
                                .textFieldStyle(MinimalTextFieldStyle())
                        }
                        
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(MinimalTextFieldStyle())
                        
                        SecureField("Senha", text: $password)
                            .textContentType(mode == .login ? .password : .newPassword)
                            .textFieldStyle(MinimalTextFieldStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 20)
                    }
                    
                    // Success Message (Signup)
                    if showSuccess {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.green)
                            
                            Text("Cadastro realizado!")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Verifique seu email para ativar a conta")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }
                    
                    // Action Button - minimalista
                    Button {
                        Task {
                            await handleAuth()
                        }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .tint(Color("Background"))
                            } else {
                                Text(mode == .login ? "Entrar" : "Criar Conta")
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
                    
                    // Info Text
                    if mode == .signup {
                        Text("Ao criar uma conta, você concorda com os termos de uso do TabNews")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle(mode == .login ? "Entrar" : "Cadastrar")
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
    
    // MARK: - Subviews
    
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
            
            Text(mode == .login ? "Bem-vindo" : "Criar conta")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(mode == .login ? "Entre para comentar e interagir" : "Junte-se à comunidade TabNews")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        if mode == .login {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !username.isEmpty && !email.isEmpty && !password.isEmpty && password.count >= 6
        }
    }
    
    // MARK: - Actions
    
    private func handleAuth() async {
        print("🚀 [AuthSheet] Iniciando autenticação - Modo: \(mode == .login ? "Login" : "Cadastro")")
        
        errorMessage = nil
        isLoading = true
        
        do {
            if mode == .login {
                print("📧 [AuthSheet] Email: \(email)")
                try await authService.login(email: email, password: password)
                
                print("✅ [AuthSheet] Login bem-sucedido!")
                
                await MainActor.run {
                    isLoading = false
                    onSuccess?()
                    dismiss()
                }
            } else {
                print("📝 [AuthSheet] Cadastrando usuário: \(username)")
                try await authService.signup(username: username, email: email, password: password)
                
                print("✅ [AuthSheet] Cadastro bem-sucedido!")
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                    
                    // Limpar campos
                    username = ""
                    email = ""
                    password = ""
                    
                    // Mudar para login após 3 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        mode = .login
                        showSuccess = false
                    }
                }
            }
        } catch {
            print("❌ [AuthSheet] Erro: \(error.localizedDescription)")
            
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Minimal Text Field Style

struct MinimalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}

#Preview("Login") {
    AuthSheet()
}

#Preview("Signup") {
    AuthSheet()
}

