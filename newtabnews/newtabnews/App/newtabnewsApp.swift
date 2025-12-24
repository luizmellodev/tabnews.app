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
        
        // Aqui você pode navegar para a newsletter específica
        if let postId = userInfo["postId"] as? String {
            print("📰 Usuário tocou na notificação do post: \(postId)")
            // TODO: Navegar para a newsletter
        }
        
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
