import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isPermissionGranted = false
    
    private init() {
        checkPermission()
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = success
            }
            if let error = error {
                print("Erro ao solicitar permissão: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDailyNewsletterNotification(for newsletter: PostRequest) {
        // Verificar se já enviamos notificação para este post
        if UserDefaults.standard.bool(forKey: "notified_\(newsletter.id ?? "")") {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Nova Newsletter Disponível!"
        content.body = newsletter.title ?? "Confira o novo conteúdo do TabNews"
        content.sound = .default
        
        // Componentes para agendar no próximo dia às 10:00
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "newsletter_\(newsletter.id ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            } else {
                // Marcar como notificado
                UserDefaults.standard.set(true, forKey: "notified_\(newsletter.id ?? "")")
            }
        }
    }
    
    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}