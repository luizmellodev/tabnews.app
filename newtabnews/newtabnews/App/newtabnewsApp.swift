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
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
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
        
        // Inscrever no tópico "all_users" para notificações gerais
        Messaging.messaging().subscribe(toTopic: "all_users") { error in
            if let error = error {
                print("❌ Erro ao inscrever no tópico 'all_users': \(error.localizedDescription)")
            } else {
                print("✅ Inscrito no tópico 'all_users' com sucesso!")
            }
        }
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
        
        // Limpar badge ao tocar na notificação
        clearBadge()
        
        // Delegar para NotificationHandler
        NotificationHandler.shared.handleNotificationTap(userInfo: userInfo)
        
        completionHandler()
    }
    
    /// Limpa o badge de notificações
    private func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("❌ Erro ao limpar badge: \(error.localizedDescription)")
            } else {
                print("✅ Badge limpo com sucesso")
            }
        }
    }
}

@main
struct newtabnewsApp: App {
    private let dependencies = AppDependencies.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        NotificationManager.shared.requestPermission()
        AppUsageTracker.shared.startTracking()
        _ = WatchSyncManager.shared
        _ = BetaTesterService.shared // Inicializa detecção de beta tester
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
        .modelContainer(for: [Folder.self, Highlight.self, Note.self, SavedPost.self])
    }
}
