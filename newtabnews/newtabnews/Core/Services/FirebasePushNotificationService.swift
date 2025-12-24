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
    
    /// Salva o device token no Firestore
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
        
        // Usar o token como document ID para evitar duplicatas
        db.collection(collectionName)
            .document(token)
            .setData(tokenData, merge: true) { error in
                if let error = error {
                    print("❌ Erro ao salvar token no Firestore: \(error.localizedDescription)")
                } else {
                    print("✅ Token salvo no Firestore com sucesso!")
                }
            }
    }
    
    /// Remove o device token do Firestore (quando o usuário desinstala ou desabilita notificações)
    func removeDeviceToken() {
        Messaging.messaging().token { token, error in
            guard let token = token, error == nil else {
                print("❌ Erro ao obter token para remoção: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            self.db.collection(self.collectionName)
                .document(token)
                .delete { error in
                    if let error = error {
                        print("❌ Erro ao remover token do Firestore: \(error.localizedDescription)")
                    } else {
                        print("✅ Token removido do Firestore com sucesso!")
                    }
                }
        }
    }
    
    /// Verifica se o usuário tem permissão para notificações
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}

