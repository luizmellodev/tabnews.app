//
//  FirebasePushNotificationService.swift
//  newtabnews
//
//  Created by Luiz Mello on 23/12/25.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

class FirebasePushNotificationService {
    static let shared = FirebasePushNotificationService()
    
    private let db = Firestore.firestore()
    private let collectionName = "tabnews_deviceTokens"
    
    private init() {}
    
    func saveDeviceToken(_ token: String) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        
        let tokenData: [String: Any] = [
            "token": token,
            "deviceId": deviceId,
            "platform": "ios",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(collectionName)
            .document(token)
            .setData(tokenData, merge: true) { error in
                if let error = error {
                    print("❌ Erro ao salvar token: \(error.localizedDescription)")
                }
            }
    }
    
    func removeDeviceToken() {
        Messaging.messaging().token { token, error in
            guard let token = token, error == nil else { return }
            
            self.db.collection(self.collectionName)
                .document(token)
                .delete { error in
                    if let error = error {
                        print("❌ Erro ao remover token: \(error.localizedDescription)")
                    }
                }
        }
    }
    
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}

