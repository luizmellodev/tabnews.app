//
//  SignupWebView.swift
//  newtabnews
//
//  Created by Luiz Mello on 07/01/26.
//

import SwiftUI
import WebKit

struct SignupWebView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                WebViewContainer(
                    url: URL(string: "https://www.tabnews.com.br/cadastro")!,
                    onLoginDetected: { _ in
                        handleSignupDetected()
                    }
                )
                
                // Overlay de sucesso
                if showSuccessMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("Cadastro realizado!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Verifique seu email para ativar a conta")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text("Fechando...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.2), radius: 20)
                    )
                }
            }
            .navigationTitle("Criar Conta")
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
    
    private func handleSignupDetected() {
        print("📧 [SignupWebView] Cadastro detectado!")
        
        showSuccessMessage = true
        
        // Fechar após 5 segundos (mais tempo para ler a mensagem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            dismiss()
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let url: URL
    var onLoginDetected: ((String) -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .interactive
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer
        private var hasDetectedCookie = false
        private var lastDetectedToken: String?
        private weak var webView: WKWebView?
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Guardar referência ao webView
            self.webView = webView
            
            // Parar de verificar se já detectou cookie
            guard !hasDetectedCookie else {
                return
            }
            
            // Verificar se há cookie de sessão após cada navegação
            checkForSessionCookie(webView: webView)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Se já detectou cookie, bloquear todas as navegações subsequentes
            if hasDetectedCookie {
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        private func checkForSessionCookie(webView: WKWebView) {
            // Evitar múltiplas detecções
            guard !hasDetectedCookie else {
                return
            }
            
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            
            cookieStore.getAllCookies { [weak self] cookies in
                guard let self = self else { return }
                
                // Verificar novamente (pode ter mudado durante o async)
                guard !self.hasDetectedCookie else { return }
                
                // Procurar pelo cookie session_id do TabNews
                if let sessionCookie = cookies.first(where: { $0.name == "session_id" && $0.domain.contains("tabnews.com.br") }) {
                    // Verificar se é um cookie novo (diferente do último detectado)
                    guard self.lastDetectedToken != sessionCookie.value else {
                        print("⚠️ [WebView] Cookie já foi processado anteriormente, ignorando...")
                        return
                    }
                    
                    print("✅ [WebView] Cookie de sessão detectado: \(sessionCookie.value)")
                    
                    // Marcar como detectado IMEDIATAMENTE para evitar race conditions
                    self.hasDetectedCookie = true
                    self.lastDetectedToken = sessionCookie.value
                    
                    // Parar qualquer navegação em progresso
                    DispatchQueue.main.async {
                        self.webView?.stopLoading()
                        self.parent.onLoginDetected?(sessionCookie.value)
                    }
                }
            }
        }
    }
}

#Preview {
    SignupWebView()
}
