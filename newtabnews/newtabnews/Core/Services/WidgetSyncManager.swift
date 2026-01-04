//
//  WidgetSyncManager.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import Foundation
import WidgetKit

/// Gerencia a sincronização de dados entre o app e os widgets
class WidgetSyncManager {
    static let shared = WidgetSyncManager()
    
    private init() {}
    
    private let sharedDefaults = UserDefaults(suiteName: "group.tabnews.com.app.tabnews-ios")
    
    // MARK: - Sync Methods
    
    /// Sincroniza posts recentes com os widgets
    func syncRecentPosts(_ posts: [PostRequest]) {
        let widgetPosts = posts.compactMap { WidgetPost(from: $0) }
        
        if let encoded = try? JSONEncoder().encode(widgetPosts) {
            sharedDefaults?.set(encoded, forKey: "RecentPosts")
            sharedDefaults?.synchronize()
        }
        
        reloadWidgets()
        print("✅ [\(type(of: self))] Sincronizados \(widgetPosts.count) posts recentes com widgets")
    }
    
    /// Sincroniza o digest da semana com os widgets
    func syncWeekDigest(_ digest: PostRequest) {
        guard let widgetDigest = WidgetPost(from: digest) else {
            print("⚠️ [\(type(of: self))] Não foi possível converter digest para WidgetPost")
            return
        }
        
        if let encoded = try? JSONEncoder().encode(widgetDigest) {
            sharedDefaults?.set(encoded, forKey: "WeekDigest")
            sharedDefaults?.synchronize()
        }
        
        reloadWidgets()
        print("✅ [\(type(of: self))] Digest sincronizado com widgets")
    }
    
    /// Força atualização de todos os widgets
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        print("🔄 [\(type(of: self))] Widgets atualizados")
    }
}
