//
//  DailyDigestManager.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/02/26.
//

import Foundation
import SwiftUI
import Combine

class DailyDigestManager: ObservableObject {
    static let shared = DailyDigestManager()
    
    @Published var todayDigest: DailyDigest?
    @Published var isLoading = false
    
    private let service: ContentServiceProtocol
    private let lastDigestDateKey = "last_daily_digest_date"
    
    init(service: ContentServiceProtocol = ContentService()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    func shouldShowBanner() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        guard hour >= 18 else { return false }
        
        if let lastDate = UserDefaults.standard.object(forKey: lastDigestDateKey) as? Date {
            if calendar.isDateInToday(lastDate) {
                return false
            }
        }
        
        return true
    }
    
    func markAsViewed() {
        UserDefaults.standard.set(Date(), forKey: lastDigestDateKey)
    }
    
    @MainActor
    func generateTodayDigest() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let posts = try await service.getContent(
                page: "1",
                perPage: "30",
                strategy: "new"
            )
            
            guard !posts.isEmpty else {
                print("⚠️ Nenhum post retornado pela API")
                isLoading = false
                return
            }
            
            let items = posts
                .map { DailyDigestItem(post: $0) }
                .sorted { $0.score > $1.score }
                .prefix(5)
            
            todayDigest = DailyDigest(
                date: Date(),
                items: Array(items)
            )
            
            print("✅ Daily Digest gerado com \(items.count) posts")
            
        } catch {
            print("❌ Erro ao gerar daily digest: \(error)")
        }
        
        isLoading = false
    }
    
}
