//
//  DeleteAccountContactView.swift
//  newtabnews
//
//  Created by Luiz Mello on 21/01/26.
//

import SwiftUI

struct DeleteAccountContactView: View {
    let username: String
    let email: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.green)
                
                Text("Conta Desconectada")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Sua conta foi desconectada e todos os dados locais foram removidos com sucesso.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Divider()
                    .padding(.vertical, 8)
                
                VStack(spacing: 16) {
                    Text("Exclusão Permanente")
                        .font(.headline)
                    
                    Text("Para excluir permanentemente sua conta do TabNews, envie um email para o suporte oficial:")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        openEmail()
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Enviar Email de Exclusão")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    
                    Text("O email será enviado para contato@tabnews.com.br com o assunto pré-preenchido.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Button("Fechar") {
                    dismiss()
                }
                .font(.body)
                .padding(.bottom, 20)
            }
            .navigationTitle("Excluir Conta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .alert("Email Não Disponível", isPresented: $showEmailError) {
                Button("OK", role: .cancel) { }
            } message: {
                var message = "Não foi possível abrir o aplicativo de email.\n\nPor favor, envie um email manualmente para:\ncontato@tabnews.com.br\n\nAssunto: Solicitação de Exclusão de Conta"
                
                if !username.isEmpty || !email.isEmpty {
                    message += "\n\nInclua no email:"
                    if !username.isEmpty {
                        message += "\nUsername: \(username)"
                    }
                    if !email.isEmpty {
                        message += "\nEmail: \(email)"
                    }
                }
                
                return Text(message)
            }
        }
    }
    
    private func openEmail() {
        let subject = "Solicitação de Exclusão de Conta"
        
        var body = "Olá,\n\nGostaria de solicitar a exclusão permanente da minha conta no TabNews.\n\n"
        
        if !username.isEmpty {
            body += "Username: \(username)\n"
        }
        
        if !email.isEmpty {
            body += "Email: \(email)\n"
        }
        
        body += "\nAguardo retorno.\n\nAtenciosamente."
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:contato@tabnews.com.br?subject=\(encodedSubject)&body=\(encodedBody)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            } else {
                showEmailError = true
            }
        }
    }
}
#Preview {
    DeleteAccountContactView(username: "usuario_exemplo", email: "[email protected]")
}
