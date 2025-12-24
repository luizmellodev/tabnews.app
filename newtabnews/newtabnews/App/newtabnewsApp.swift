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

// MARK: - Models

/// Enum para tipos de notificação (type safety)
enum NotificationType: String {
    case newsletter
    case testNewsletter = "test_newsletter"
    case relevant
    case testRelevant = "test_relevant"
    
    var isNewsletter: Bool {
        self == .newsletter || self == .testNewsletter
    }
    
    var isRelevant: Bool {
        self == .relevant || self == .testRelevant
    }
}

/// Struct para passar dados do post via NotificationCenter
struct PostDeepLinkData {
    let owner: String
    let slug: String
    let type: NotificationType
}

// MARK: - Notification Names

extension Notification.Name {
    static let openNewsletterTab = Notification.Name("openNewsletterTab")
    static let openPostFromNotification = Notification.Name("openPostFromNotification")
}

// AppDelegate para configurar Firebase e notificações push
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
    // Notificação recebida quando o app está em foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Mostrar banner, som e badge mesmo com app aberto
        completionHandler([.banner, .sound, .badge])
    }
    
    // Usuário tocou na notificação
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("📱 Notificação tocada. Dados: \(userInfo)")
        
        guard let type = userInfo["type"] as? String else {
            print("⚠️ Tipo de notificação não encontrado")
            completionHandler()
            return
        }
        
        // Verificar se tem dados do post (owner e slug)
        if let owner = userInfo["owner"] as? String,
           let slug = userInfo["slug"] as? String,
           !owner.isEmpty,
           !slug.isEmpty {
            
            // NEWSLETTER: navegar para aba Newsletter + abrir post
            if type == "newsletter" || type == "test_newsletter" {
                print("📰 Notificação de Newsletter - navegando para Newsletter e abrindo post: \(owner)/\(slug)")
                
                let postData = PostDeepLinkData(owner: owner, slug: slug, type: type)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(
                        name: .openPostFromNotification,
                        object: postData
                    )
                }
                
                completionHandler()
                return
            }
            
            // POST RELEVANTE: abrir post específico na Home
            if type == "relevant" || type == "test_relevant" {
                print("🔥 Notificação de Post Relevante - abrindo post na Home: \(owner)/\(slug)")
                
                let postData = PostDeepLinkData(owner: owner, slug: slug, type: type)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(
                        name: .openPostFromNotification,
                        object: postData
                    )
                }
                
                completionHandler()
                return
            }
        } else {
            // Fallback: sem dados do post, apenas abrir aba Newsletter
            if type == "newsletter" || type == "test_newsletter" {
                print("📰 Notificação de Newsletter sem dados - apenas abrindo aba")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .openNewsletterTab, object: nil)
                }
                
                completionHandler()
                return
            }
        }
        
        // Fallback: tipo desconhecido
        print("⚠️ Tipo de notificação desconhecido: \(type)")
        completionHandler()
    }
}

@main
struct newtabnewsApp: App {
    // Registrar AppDelegate para configuração do Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        NotificationManager.shared.requestPermission()
        AppUsageTracker.shared.startTracking() // Iniciar tracking de tempo
        
//        let tabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.configureWithDefaultBackground()
//        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(searchText: "")
        }
        .modelContainer(for: [Folder.self, Highlight.self, Note.self])
    }
}
