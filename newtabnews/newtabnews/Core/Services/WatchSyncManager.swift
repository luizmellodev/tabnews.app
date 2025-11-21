//
//  WatchSyncManager.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/11/25.
//

import Foundation
import WatchConnectivity

class WatchSyncManager: NSObject {
    static let shared = WatchSyncManager()
    
    private var session: WCSession?
    
    private override init() {
        super.init()
        
        #if !os(watchOS)
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("📱 WatchSync ativado")
        }
        #else
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("⌚ WatchSync ativado")
        }
        #endif
    }
    
    // MARK: - Enviar (iOS → Watch)
    #if !os(watchOS)
    func syncToWatch(posts: [PostRequest], likedPosts: [PostRequest], stats: [String: Int]) {
        guard let session = session, session.activationState == .activated else {
            print("📱 ❌ Session não ativada: \(session?.activationState.rawValue ?? -1)")
            return
        }
        
        print("📱 Sincronizando:")
        print("   Posts recentes: \(posts.count)")
        print("   Posts curtidos: \(likedPosts.count)")
        print("   ❤️ Total curtidos: \(stats["liked"] ?? 0)")
        print("   🖍 Destaques: \(stats["highlights"] ?? 0)")
        print("   📝 Anotações: \(stats["notes"] ?? 0)")
        print("   📁 Pastas: \(stats["folders"] ?? 0)")
        
        // Codificar posts recentes
        guard let postsData = try? JSONEncoder().encode(posts),
              let postsJSON = String(data: postsData, encoding: .utf8) else {
            print("📱 ❌ Erro ao codificar posts")
            return
        }
        
        // Codificar posts curtidos
        guard let likedData = try? JSONEncoder().encode(likedPosts),
              let likedJSON = String(data: likedData, encoding: .utf8) else {
            print("📱 ❌ Erro ao codificar curtidos")
            return
        }
        
        // Mensagem completa
        let message: [String: Any] = [
            "posts": postsJSON,
            "likedPosts": likedJSON,
            "stats": stats
        ]
        
        // Enviar
        do {
            try session.updateApplicationContext(message)
            print("📱 ✅ Enviado com sucesso!")
        } catch {
            print("📱 ❌ Erro: \(error.localizedDescription)")
        }
    }
    #endif
}

// MARK: - Delegate
extension WatchSyncManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Erro na ativação: \(error.localizedDescription)")
        } else {
            #if os(watchOS)
            print("⌚ ✅ Session ativa no Watch")
            #else
            print("📱 ✅ Session ativa no iPhone")
            #endif
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        #if os(watchOS)
        print("⌚ 📥 Dados recebidos!")
        
        // Posts recentes
        if let postsJSON = applicationContext["posts"] as? String,
           let postsData = postsJSON.data(using: .utf8) {
            UserDefaults.standard.set(postsData, forKey: "WatchPosts")
            
            if let posts = try? JSONDecoder().decode([PostRequest].self, from: postsData) {
                print("   ✅ \(posts.count) posts recentes salvos")
            }
        }
        
        // Posts curtidos
        if let likedJSON = applicationContext["likedPosts"] as? String {
            print("   📦 JSON curtidos recebido: \(likedJSON.prefix(200))...")
            
            if let likedData = likedJSON.data(using: .utf8) {
                print("   📦 Data criado: \(likedData.count) bytes")
                UserDefaults.standard.set(likedData, forKey: "WatchLikedPosts")
                
                if let liked = try? JSONDecoder().decode([PostRequest].self, from: likedData) {
                    print("   ✅ \(liked.count) posts curtidos decodificados e salvos")
                    for (i, post) in liked.enumerated() {
                        print("      \(i+1). \(post.title ?? "sem título")")
                    }
                } else {
                    print("   ❌ Falha ao decodificar posts curtidos")
                }
            } else {
                print("   ❌ Falha ao converter JSON para Data")
            }
        } else {
            print("   ⚠️ Nenhum JSON de posts curtidos no applicationContext")
        }
        
        // Stats
        if let stats = applicationContext["stats"] as? [String: Int] {
            UserDefaults.standard.set(stats["liked"] ?? 0, forKey: "WatchLiked")
            UserDefaults.standard.set(stats["highlights"] ?? 0, forKey: "WatchHighlights")
            UserDefaults.standard.set(stats["notes"] ?? 0, forKey: "WatchNotes")
            UserDefaults.standard.set(stats["folders"] ?? 0, forKey: "WatchFolders")
            
            print("   ✅ Stats: ❤️\(stats["liked"] ?? 0) 🖍\(stats["highlights"] ?? 0)")
        }
        
        UserDefaults.standard.synchronize()
        print("   💾 Tudo salvo!")
        #endif
    }
    
    #if !os(watchOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
}

