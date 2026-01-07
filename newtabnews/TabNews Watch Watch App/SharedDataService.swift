//
//  SharedDataService.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/11/25.
//

import Foundation
import SwiftUI

struct SharedDataService {
    private static let suiteName = "group.luizmello.tabnews"
    private static var sharedDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            print("❌ ERRO CRÍTICO: Não foi possível criar UserDefaults com suiteName: \(suiteName)")
            print("   Isso geralmente indica que o App Group não está configurado corretamente.")
            print("   Verificando configuração...")
            
            // Tentar descobrir o problema
            #if os(iOS)
            print("   Platform: iOS")
            #else
            print("   Platform: watchOS")
            #endif
            
            print("   ⚠️ USANDO UserDefaults.standard COMO FALLBACK")
            return UserDefaults.standard
        }
        
        print("✅ UserDefaults criado com sucesso para: \(suiteName)")
        return defaults
    }
    
    // MARK: - Posts Curtidos
    static func saveLikedPosts(_ posts: [PostRequest]) {
        if let encoded = try? JSONEncoder().encode(posts) {
            sharedDefaults.set(encoded, forKey: "LikedContent")
            sharedDefaults.synchronize()
        }
    }
    
    static func fetchLikedPosts() -> [PostRequest] {
        guard let data = sharedDefaults.data(forKey: "LikedContent"),
              let decoded = try? JSONDecoder().decode([PostRequest].self, from: data) else {
            return []
        }
        return decoded
    }
    
    // MARK: - Posts Recentes (para Watch)
    static func saveRecentPosts(_ posts: [PostRequest]) {
        print("📤 [SharedDataService] Tentando salvar \(posts.count) posts")
        print("   Suite Name: \(suiteName)")
        
        sharedDefaults.set("TESTE-\(Date())", forKey: "TestSync")
        sharedDefaults.set(posts.count, forKey: "PostCount")
        sharedDefaults.synchronize()
        print("   📝 Valores de teste salvos (TestSync, PostCount)")
        
        if let encoded = try? JSONEncoder().encode(posts) {
            sharedDefaults.set(encoded, forKey: "RecentPosts")
            sharedDefaults.synchronize()
            
            print("   ✅ Posts salvos! Tamanho: \(encoded.count) bytes")
            
            if let verificacao = sharedDefaults.data(forKey: "RecentPosts") {
                print("   ✅ Verificação: Dados encontrados (\(verificacao.count) bytes)")
            } else {
                print("   ❌ ERRO: Dados não foram salvos!")
            }
            
            let allKeys = sharedDefaults.dictionaryRepresentation().keys
            let relevantKeys = allKeys.filter { $0.contains("Recent") || $0.contains("Post") || $0.contains("Test") }
            print("   📋 Chaves relevantes: \(relevantKeys)")
        } else {
            print("   ❌ ERRO: Falha ao codificar posts!")
        }
    }
    
    static func fetchRecentPosts() -> [PostRequest] {
        print("📥 [SharedDataService] Tentando carregar posts...")
        print("   Suite Name: \(suiteName)")
        
        if let testValue = sharedDefaults.string(forKey: "TestSync") {
            print("   ✅ TestSync encontrado: \(testValue)")
        } else {
            print("   ❌ TestSync NÃO encontrado - App Group não está funcionando!")
        }
        
        if let postCount = sharedDefaults.object(forKey: "PostCount") as? Int {
            print("   ✅ PostCount encontrado: \(postCount)")
        } else {
            print("   ❌ PostCount NÃO encontrado")
        }
        
        let allKeys = sharedDefaults.dictionaryRepresentation().keys
        let relevantKeys = allKeys.filter { $0.contains("Recent") || $0.contains("Post") || $0.contains("Test") || $0.contains("Liked") }
        print("   📋 Chaves relevantes: \(relevantKeys)")
        print("   📋 Total de chaves: \(allKeys.count)")
        
        guard let data = sharedDefaults.data(forKey: "RecentPosts") else {
            print("   ❌ Nenhum dado encontrado para chave 'RecentPosts'")
            print("   💡 Isso indica que o App Group não está compartilhando dados corretamente!")
            return []
        }
        
        print("   ✅ Dados encontrados! Tamanho: \(data.count) bytes")
        
        guard let decoded = try? JSONDecoder().decode([PostRequest].self, from: data) else {
            print("   ❌ ERRO ao decodificar posts!")
            return []
        }
        
        print("   ✅ Decodificados \(decoded.count) posts com sucesso!")
        return decoded
    }
    
    // MARK: - Folders (Resumo básico)
    struct FolderSummary: Codable {
        let id: String
        let name: String
        let icon: String
        let colorHex: String
        let postCount: Int
    }
    
    static func saveFoldersSummary(_ folders: [FolderSummary]) {
        if let encoded = try? JSONEncoder().encode(folders) {
            sharedDefaults.set(encoded, forKey: "FoldersSummary")
            sharedDefaults.synchronize()
        }
    }
    
    static func fetchFoldersSummary() -> [FolderSummary] {
        guard let data = sharedDefaults.data(forKey: "FoldersSummary"),
              let decoded = try? JSONDecoder().decode([FolderSummary].self, from: data) else {
            return []
        }
        return decoded
    }
    
    // MARK: - Configurações
    static func saveSettings(viewInApp: Bool, theme: String) {
        sharedDefaults.set(viewInApp, forKey: "viewInApp")
        sharedDefaults.set(theme, forKey: "theme")
        sharedDefaults.synchronize()
    }
    
    static func getViewInApp() -> Bool {
        return sharedDefaults.bool(forKey: "viewInApp")
    }
    
    static func getTheme() -> String {
        return sharedDefaults.string(forKey: "theme") ?? "system"
    }
    
    // MARK: - Estatísticas (para mostrar no Watch)
    static func saveStats(liked: Int, highlights: Int, notes: Int, folders: Int) {
        sharedDefaults.set(liked, forKey: "stat_liked")
        sharedDefaults.set(highlights, forKey: "stat_highlights")
        sharedDefaults.set(notes, forKey: "stat_notes")
        sharedDefaults.set(folders, forKey: "stat_folders")
        sharedDefaults.synchronize()
    }
    
    static func getStats() -> (liked: Int, highlights: Int, notes: Int, folders: Int) {
        return (
            liked: sharedDefaults.integer(forKey: "stat_liked"),
            highlights: sharedDefaults.integer(forKey: "stat_highlights"),
            notes: sharedDefaults.integer(forKey: "stat_notes"),
            folders: sharedDefaults.integer(forKey: "stat_folders")
        )
    }
}
