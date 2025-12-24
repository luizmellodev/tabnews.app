//
//  NotificationHandler.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import Foundation

class NotificationHandler {
        
    static let shared = NotificationHandler()
    
    private init() {}
    
    /// Processa o toque na notificação e navega para o destino apropriado
    func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        guard let typeString = userInfo["type"] as? String,
              let notificationType = NotificationType(rawValue: typeString) else {
            print("⚠️ Tipo de notificação inválido ou não encontrado")
            return
        }
        
        // Extrair dados do post (se disponíveis)
        let owner = userInfo["owner"] as? String ?? ""
        let slug = userInfo["slug"] as? String ?? ""
        
        // Se tem dados completos do post, abrir post específico
        if !owner.isEmpty && !slug.isEmpty {
            openPost(owner: owner, slug: slug, type: notificationType)
        } else {
            // Fallback: apenas abrir aba Newsletter (se for newsletter)
            if notificationType.isNewsletter {
                openNewsletterTab()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Abre um post específico via deep link
    private func openPost(owner: String, slug: String, type: NotificationType) {
        let icon = type.isNewsletter ? "📰" : "🔥"
        let destination = type.isNewsletter ? "Newsletter" : "Home"
        
        print("\(icon) Abrindo post em \(destination): \(owner)/\(slug)")
        
        let postData = PostDeepLinkData(owner: owner, slug: slug, type: type)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(
                name: .openPostFromNotification,
                object: postData
            )
        }
    }
    
    /// Abre apenas a aba Newsletter (sem post específico)
    private func openNewsletterTab() {
        print("📰 Abrindo aba Newsletter")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .openNewsletterTab, object: nil)
        }
    }
}
