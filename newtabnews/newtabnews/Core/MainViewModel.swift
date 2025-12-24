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
        do {
            self.content = try await service.getContent(page: "1", perPage: "5", strategy: currentStrategy.rawValue)
            self.state = .requestSucceeded
        } catch {
            self.state = .requestFailed
            print(error)
        }
    }
    
    @MainActor
    func fetchContent(with strategy: ContentStrategy) async {
        self.currentStrategy = strategy
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
        
        NotificationCenter.default.post(name: .postsLoaded, object: nil)
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
