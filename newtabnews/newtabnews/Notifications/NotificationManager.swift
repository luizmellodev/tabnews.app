//
//  NotificationManager.swift
//  newtabnews
//
//  Created by Luiz Mello on 31/03/25.
//

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
    
    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Envia notificações imediatas para newsletters novas (criadas hoje)
    func notifyNewNewsletters(_ newsletters: [PostRequest]) {
        guard isPermissionGranted else { return }
        
        let todayNewsletters = newsletters.filter { newsletter in
            isCreatedToday(createdAt: newsletter.createdAt)
        }
        
        for newsletter in todayNewsletters {
            // Verificar se já notificamos esse post
            let notificationKey = "newsletter_shown_\(newsletter.id ?? "")"
            if UserDefaults.standard.bool(forKey: notificationKey) {
                continue
            }
            
            // Criar e enviar notificação imediata
            let content = UNMutableNotificationContent()
            content.title = "📰 Nova Newsletter!"
            content.body = newsletter.title ?? "Nova edição disponível no TabNews"
            content.sound = .default
            content.badge = 1
            
            // Trigger imediato (1 segundo)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "new_newsletter_\(newsletter.id ?? UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Erro ao enviar notificação de newsletter nova: \(error.localizedDescription)")
                } else {
                    // Marcar como já notificado
                    UserDefaults.standard.set(true, forKey: notificationKey)
                    print("Notificação enviada para: \(newsletter.title ?? "sem título")")
                }
            }
        }
    }
    
    // Verifica se um post foi criado hoje
    private func isCreatedToday(createdAt: String?) -> Bool {
        guard let createdAtString = createdAt else {
            return false
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let createdDate = dateFormatter.date(from: createdAtString) else {
            return false
        }
        
        let calendar = Calendar.current
        let createdComponents = calendar.dateComponents([.year, .month, .day], from: createdDate)
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        return createdComponents.year == currentComponents.year &&
               createdComponents.month == currentComponents.month &&
               createdComponents.day == currentComponents.day
    }
}
