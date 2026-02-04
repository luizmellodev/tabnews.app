//
//  NativeLoginView.swift
//  newtabnews
//
//  Created by Luiz Mello on 03/02/26.
//

import SwiftUI

struct NativeLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: Bool = false
    @State private var showPassword: Bool = false
    @State private var emailSuggestions: [String] = []
    @State private var showEmailSuggestions: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    // Domínios populares para autocomplete
    private let popularDomains = [
        "gmail.com",
        "outlook.com",
        "hotmail.com",
        "yahoo.com",
        "icloud.com",
        "protonmail.com",
        "uol.com.br",
        "terra.com.br",
        "bol.com.br"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 40)
                        
                        // Logo/Ícone
                        VStack(spacing: 16) {
                            Image(systemName: "square.text.square.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.primary)
                            
                            Text("Entrar")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("É necessário ter uma conta existente no TabNews para entrar.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Formulário
                        VStack(spacing: 20) {
                            // Email com autocomplete
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                
                                VStack(spacing: 0) {
                                    TextField(
                                        "",
                                        text: $email,
                                        prompt: Text("seu@email.com").foregroundColor(.gray)
                                    )
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .email)
                                    .padding()
                                    .foregroundStyle(.primary)
                                    .tint(.primary)
                                    .textFieldStyle(.plain)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .email ? Color.primary : Color.clear, lineWidth: 1)
                                    )
                                    .onChange(of: email) { _, newValue in
                                        updateEmailSuggestions(for: newValue)
                                    }
                                    
                                    // Sugestões de email
                                    if showEmailSuggestions && !emailSuggestions.isEmpty {
                                        VStack(spacing: 0) {
                                            ForEach(emailSuggestions, id: \.self) { suggestion in
                                                Button {
                                                    selectEmailSuggestion(suggestion)
                                                } label: {
                                                    HStack {
                                                        Text(suggestion)
                                                            .font(.subheadline)
                                                            .foregroundStyle(.primary)
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 12)
                                                    .background(Color(.systemBackground))
                                                }
                                                .buttonStyle(.plain)
                                                
                                                if suggestion != emailSuggestions.last {
                                                    Divider()
                                                        .padding(.leading, 16)
                                                }
                                            }
                                        }
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        .padding(.top, 4)
                                    }
                                }
                            }
                            
                            // Senha com toggle de visibilidade
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Senha")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    Group {
                                        if showPassword {
                                            TextField("Sua senha", text: $password)
                                        } else {
                                            SecureField("Sua senha", text: $password)
                                        }
                                    }
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .accentColor(.primary)
                                    .foregroundColor(.primary)
                                    
                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .password ? Color.primary : Color.clear, lineWidth: 1)
                                )
                            }
                            
                            // Mensagem de erro
                            if let errorMessage = errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                            }
                            
                            // Botão de login
                            Button {
                                Task {
                                    await performLogin()
                                }
                            } label: {
                                HStack {
                                    if isLoggingIn {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Entrar")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isFormValid && !isLoggingIn ? Color.primary : Color.primary.opacity(0.5))
                                .foregroundStyle(Color("Background"))
                                .cornerRadius(12)
                            }
                            .disabled(!isFormValid || isLoggingIn)
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
                
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
            .onSubmit {
                if focusedField == .email {
                    focusedField = .password
                } else {
                    if isFormValid {
                        Task {
                            await performLogin()
                        }
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func updateEmailSuggestions(for text: String) {
        guard text.contains("@") else {
            emailSuggestions = []
            showEmailSuggestions = false
            return
        }
        
        let parts = text.split(separator: "@", maxSplits: 1)
        guard parts.count == 2 else {
            emailSuggestions = []
            showEmailSuggestions = false
            return
        }
        
        let localPart = String(parts[0])
        let domainPart = String(parts[1])
        
        // Se já tem um domínio completo, não mostrar sugestões
        if domainPart.contains(".") && !domainPart.hasSuffix(".") {
            emailSuggestions = []
            showEmailSuggestions = false
            return
        }
        
        // Filtrar domínios que começam com o que o usuário digitou
        let filtered = popularDomains.filter { domain in
            domain.hasPrefix(domainPart.lowercased())
        }
        
        // Criar sugestões completas
        emailSuggestions = filtered.prefix(5).map { domain in
            "\(localPart)@\(domain)"
        }
        
        showEmailSuggestions = !emailSuggestions.isEmpty && !domainPart.isEmpty
    }
    
    private func selectEmailSuggestion(_ suggestion: String) {
        email = suggestion
        emailSuggestions = []
        showEmailSuggestions = false
        focusedField = .password
    }
    
    private func parseErrorMessage(from error: Error) -> String {
        // Se for ValidationError (preserva mensagem original da API)
        if let validationError = error as? ValidationError {
            return validationError.message
        }
        
        // Se for NetworkError com APIError, usar mensagem direta da API
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let apiError):
                return apiError.message
            default:
                return networkError.localizedDescription
            }
        }
        
        // Se for AuthError, usar mensagem localizada
        if let authError = error as? AuthError {
            return authError.localizedDescription
        }
        
        // Fallback: retornar mensagem do erro
        let errorString = error.localizedDescription
        return errorString.isEmpty ? "Erro desconhecido. Tente novamente." : errorString
    }
    
    private func performLogin() async {
        errorMessage = nil
        isLoggingIn = true
        showEmailSuggestions = false
        
        do {
            try await authService.login(email: email, password: password)
            
            await MainActor.run {
                isLoggingIn = false
                showSuccessMessage = true
                
                // Fechar após 1.5 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        } catch {
            await MainActor.run {
                isLoggingIn = false
                errorMessage = parseErrorMessage(from: error)
            }
        }
    }
}

#Preview {
    NativeLoginView()
}
