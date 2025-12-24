//
//  NotificationType.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import Foundation

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

struct PostDeepLinkData {
    let owner: String
    let slug: String
    let type: NotificationType
}

extension Notification.Name {
    /// Notificação para abrir apenas a aba Newsletter
    static let openNewsletterTab = Notification.Name("openNewsletterTab")
    
    /// Notificação para abrir um post específico via deep link
    static let openPostFromNotification = Notification.Name("openPostFromNotification")
}
