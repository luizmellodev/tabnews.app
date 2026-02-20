//
//  MainViewModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import Foundation


@Observable
class MainViewModel {
    
    private let service: ContentServiceProtocol
    var likedList: [PostRequest] = []
    var content: [PostRequest] = []
    var state: DefaultViewState = .loading
    var currentStrategy: ContentStrategy = .relevant
    
    var currentPage: Int = 1
    var isLoadingMore: Bool = false
    var hasMorePages: Bool = true
    private let postsPerPage: Int = 10
    private let maxCachedPages: Int = 5
    
    let defaults = UserDefaults.standard
    
    init(service: ContentServiceProtocol = ContentService()) {
        self.service = service
    }
}

// MARK: - Fetch Functions
extension MainViewModel {
    
    @MainActor
    func fetchContent() async {
        self.state = .loading
        self.currentPage = 1
        self.hasMorePages = true
        
        do {
            let newPosts = try await service.getContent(
                page: "\(currentPage)",
                perPage: "\(postsPerPage)",
                strategy: currentStrategy.rawValue
            )
            
            self.content = newPosts
            self.hasMorePages = newPosts.count == postsPerPage
            self.state = .requestSucceeded
        } catch {
            self.state = .requestFailed
            print(error)
        }
    }
    
    @MainActor
    func fetchContent(with strategy: ContentStrategy) async {
        let strategyChanged = self.currentStrategy != strategy
        self.currentStrategy = strategy
        
        if strategyChanged {
            self.currentPage = 1
            self.hasMorePages = true
            self.content = []
        }
        
        await fetchContent()
        await fetchPost()
    }
    
    @MainActor
    func fetchPost() async {
        for index in content.indices {
            do {
                let response = try await service.getPost(
                    user: content[index].ownerUsername ?? "erro",
                    slug: content[index].slug ?? "erro"
                )
                content[index] = response
            } catch {
                self.state = .requestFailed
                print(error)
            }
        }
        
        saveCachedContent(page: currentPage)
        
        // Sincronizar com widgets
        WidgetSyncManager.shared.syncRecentPosts(content)
        
        // Sincronizar digest em background
        Task.detached(priority: .background) {
            await self.syncDigestForWidget()
        }
        
        NotificationCenter.default.post(name: .postsLoaded, object: nil)
    }
    
    @MainActor
    func syncDigestForWidget() async {
        do {
            // Buscar o digest mais recente
            let digests = try await service.getDigest(page: "1", perPage: "1", strategy: "new")
            
            guard let latestDigest = digests.first else {
                print("⚠️ [MainViewModel] Nenhum digest encontrado")
                return
            }
            
            // Buscar o conteúdo completo do digest
            let fullDigest = try await service.getPost(
                user: latestDigest.ownerUsername ?? "",
                slug: latestDigest.slug ?? ""
            )
            
            // Sincronizar com widgets
            WidgetSyncManager.shared.syncWeekDigest(fullDigest)
            print("✅ [MainViewModel] Digest sincronizado automaticamente para widgets")
            
        } catch {
            print("⚠️ [MainViewModel] Erro ao sincronizar digest: \(error)")
        }
    }
    
    @MainActor
    func fetchNextPage() async {
        guard !isLoadingMore && hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let newPosts = try await service.getContent(
                page: "\(currentPage)",
                perPage: "\(postsPerPage)",
                strategy: currentStrategy.rawValue
            )
            
            if newPosts.isEmpty || newPosts.count < postsPerPage {
                hasMorePages = false
            }
            
            for index in newPosts.indices {
                var post = newPosts[index]
                do {
                    let response = try await service.getPost(
                        user: post.ownerUsername ?? "erro",
                        slug: post.slug ?? "erro"
                    )
                    self.content.append(response)
                } catch {
                    print("Error fetching post details: \(error)")
                }
            }
            
            saveCachedContent(page: currentPage)
            isLoadingMore = false
        } catch {
            print("Error fetching next page: \(error)")
            currentPage -= 1
            isLoadingMore = false
        }
    }
    
    @MainActor
    func resetPagination() async {
        currentPage = 1
        hasMorePages = true
        content = []
        clearOldCache()
        await fetchContent()
        await fetchPost()
    }
    
    @MainActor
    func loadCachedContent() {
        let cacheKey = "CachedPosts_\(currentStrategy.rawValue)_page1"
        let timestampKey = "CachedPosts_\(currentStrategy.rawValue)_timestamp"
        
        if let timestamp = defaults.object(forKey: timestampKey) as? Date {
            let hoursSinceCache = Date().timeIntervalSince(timestamp) / 3600
            
            if hoursSinceCache > 1 {
                clearOldCache()
                return
            }
        }
        
        if let cachedData = defaults.object(forKey: cacheKey) as? Data {
            let decoder = JSONDecoder()
            if let cachedPosts = try? decoder.decode([PostRequest].self, from: cachedData) {
                self.content = cachedPosts
                self.state = .requestSucceeded
                self.currentPage = 1
                self.hasMorePages = true
            }
        }
    }
    
    private func saveCachedContent(page: Int) {
        guard page <= maxCachedPages else { return }
        
        let cacheKey = "CachedPosts_\(currentStrategy.rawValue)_page\(page)"
        let timestampKey = "CachedPosts_\(currentStrategy.rawValue)_timestamp"
        let encoder = JSONEncoder()
        
        let startIndex = (page - 1) * postsPerPage
        let endIndex = min(startIndex + postsPerPage, content.count)
        
        guard startIndex < content.count else { return }
        
        let postsForPage = Array(content[startIndex..<endIndex])
        
        if let encoded = try? encoder.encode(postsForPage) {
            defaults.set(encoded, forKey: cacheKey)
            
            if page == 1 {
                defaults.set(Date(), forKey: timestampKey)
            }
        }
    }
    
    private func clearOldCache() {
        for page in 1...maxCachedPages {
            let cacheKey = "CachedPosts_\(currentStrategy.rawValue)_page\(page)"
            defaults.removeObject(forKey: cacheKey)
        }
        
        let timestampKey = "CachedPosts_\(currentStrategy.rawValue)_timestamp"
        defaults.removeObject(forKey: timestampKey)
    }
}

// MARK: - Notification
extension Notification.Name {
    static let postsLoaded = Notification.Name("postsLoaded")
    static let likedListUpdated = Notification.Name("likedListUpdated")
}

// MARK: - UserDefaults
extension MainViewModel {
    func saveInAppSettings(viewInApp: Bool) {
        defaults.bool(forKey: "viewInApp")
    }
    
    func likeContentList(content: PostRequest) {
        let alreadyExists = likedList.contains { existingPost in
            isSamePost(existingPost, content)
        }
        
        if !alreadyExists {
            self.likedList.append(content)
            saveLikedContent()
            
            GamificationManager.shared.trackPostLiked()
        }
    }
    
    func removeContentList(content: PostRequest) {
        self.likedList.removeAll { existingPost in
            isSamePost(existingPost, content)
        }
        saveLikedContent()
    }
    
    func clearAllLikedContent() {
        self.likedList = []
        saveLikedContent()
    }
    
    private func isSamePost(_ post1: PostRequest, _ post2: PostRequest) -> Bool {
        if let id1 = post1.id, let id2 = post2.id, !id1.isEmpty, !id2.isEmpty {
            return id1 == id2
        }
        
        if let title1 = post1.title, let title2 = post2.title,
           let owner1 = post1.ownerUsername, let owner2 = post2.ownerUsername {
            return title1 == title2 && owner1 == owner2
        }
        
        return post1.title == post2.title
    }
    
    private func saveLikedContent() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(likedList) {
            defaults.set(encoded, forKey: "LikedContent")
        }
        
        SharedDataService.saveLikedPosts(likedList)
        NotificationCenter.default.post(name: .likedListUpdated, object: nil)
    }
    
    func getLikedContent() {
        if let likedContent = defaults.object(forKey: "LikedContent") as? Data {
            let decoder = JSONDecoder()
            if let loadedContent = try? decoder.decode([PostRequest].self, from: likedContent) {
                self.likedList = removeDuplicates(from: loadedContent)
                saveLikedContent()
            }
        }
    }
    
    private func removeDuplicates(from posts: [PostRequest]) -> [PostRequest] {
        var seen: Set<String> = []
        return posts.filter { post in
            let identifier = post.id ?? post.title ?? UUID().uuidString
            if seen.contains(identifier) {
                return false
            }
            seen.insert(identifier)
            return true
        }
    }
    
}
