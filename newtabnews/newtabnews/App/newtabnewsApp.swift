//
//  newtabnewsApp.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseMessaging
import UserNotifications

// MARK: - AppDelegate

/// AppDelegate para configurar Firebase e notificações push
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configurar Firebase
        FirebaseApp.configure()
        
        // Configurar Firebase Messaging delegate
        Messaging.messaging().delegate = self
        
        // Configurar UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Registrar para notificações remotas
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Callback quando o device token é registrado com sucesso
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Passar o token para o Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Callback quando falha ao registrar
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Falha ao registrar para notificações remotas: \(error.localizedDescription)")
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    // Callback quando o FCM token é gerado/atualizado
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("✅ FCM Token recebido: \(token)")
        
        // Salvar token no Firestore para a Cloud Function usar
        FirebasePushNotificationService.shared.saveDeviceToken(token)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Notificação recebida quando o app está em foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Mostrar banner, som e badge mesmo com app aberto
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Usuário tocou na notificação
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("📱 Notificação tocada. Dados: \(userInfo)")
        
        handleNotificationTap(userInfo: userInfo)
        completionHandler()
    }
    
    // MARK: - Private Methods
    
    /// Processa o toque na notificação e navega para o destino apropriado
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
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

@main
struct newtabnewsApp: App {
    private let dependencies = AppDependencies.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        NotificationManager.shared.requestPermission()
        AppUsageTracker.shared.startTracking() // Iniciar tracking de tempo
    }
        
    var body: some Scene {
        WindowGroup {
            ContentView(
                searchText: "",
                contentService: dependencies.contentService,
                viewModel: dependencies.makeMainViewModel(),
                newsletterVM: dependencies.makeNewsletterViewModel()
            )
        }
        .modelContainer(for: [Folder.self, Highlight.self, Note.self])
    }
}
