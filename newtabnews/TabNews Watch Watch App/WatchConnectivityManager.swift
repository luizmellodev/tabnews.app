//
//  WatchConnectivityManager.swift
//  TabNews Watch Watch App
//
//  Created by Luiz Mello on 24/12/25.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()
    
    private var session: WCSession?
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func syncLikedPostsToiPhone() {
        guard let session = session,
              session.activationState == .activated,
              session.isReachable else {
            return
        }
        
        guard let likedData = UserDefaults.standard.data(forKey: "WatchLikedPosts"),
              let likedJSON = String(data: likedData, encoding: .utf8) else {
            return
        }
        
        let message: [String: Any] = [
            "watchLikedPosts": likedJSON
        ]
        
        do {
            try session.updateApplicationContext(message)
        } catch {
            print("⌚ Erro ao enviar likes para iPhone: \(error)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("⌚ Watch session ativada")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("⌚ [WatchConnectivityManager] Recebendo dados do iPhone...")
        
        if let postsJSON = applicationContext["posts"] as? String,
           let postsData = postsJSON.data(using: .utf8) {
            UserDefaults.standard.set(postsData, forKey: "WatchPosts")
            print("⌚ [WatchConnectivityManager] Posts atualizados")
        }
        
        if let likedJSON = applicationContext["likedPosts"] as? String,
           let likedData = likedJSON.data(using: .utf8) {
            UserDefaults.standard.set(likedData, forKey: "WatchLikedPosts")
            print("⌚ [WatchConnectivityManager] Posts curtidos atualizados")
        }
        
        if let stats = applicationContext["stats"] as? [String: Int] {
            UserDefaults.standard.set(stats["liked"] ?? 0, forKey: "WatchLiked")
            UserDefaults.standard.set(stats["highlights"] ?? 0, forKey: "WatchHighlights")
            UserDefaults.standard.set(stats["notes"] ?? 0, forKey: "WatchNotes")
            UserDefaults.standard.set(stats["folders"] ?? 0, forKey: "WatchFolders")
            print("⌚ [WatchConnectivityManager] Stats atualizadas")
        }
        
        UserDefaults.standard.synchronize()
    }
}

