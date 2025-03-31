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
    
    // ADD: Função para teste rápido de notificação
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Teste de Notificação"
        content.body = "Esta é uma notificação de teste (10 segundos)"
        content.sound = .default
        
        // Trigger para 10 segundos
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação de teste: \(error.localizedDescription)")
            } else {
                print("Notificação de teste agendada com sucesso!")
            }
        }
    }
    
    // Restante do código permanece igual...
}