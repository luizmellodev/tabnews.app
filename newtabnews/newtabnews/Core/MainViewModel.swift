//
//  MainViewModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import Foundation

class MainViewModel: ObservableObject {
    
    private let service: ContentServiceProtocol
    @Published var likedList: [PostRequest] = []
    @Published var content: [PostRequest] = []
    @Published var state: DefaultViewState = .started
    
    let defaults = UserDefaults.standard
    
    init(service: ContentServiceProtocol = ContentService()) {
        self.service = service
    }
}

// MARK: - Fetch Functions
extension MainViewModel {
    
    // Get tabnews titles
    @MainActor
    func fetchContent() async {
        self.state = .loading
        do {
            self.content = try await service.getContent(page: "1", perPage: "5", strategy: "relevant")
            self.state = .requestSucceeded
        } catch {
            self.state = .requestFailed
            print(error)
        }
    }
    
    // Get tabnews post (content)
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
    }
}

// MARK: - UserDefaults
extension MainViewModel {
    func saveInAppSettings(viewInApp: Bool) {
        defaults.bool(forKey: "viewInApp")
    }
    
    func likeContentList(content: PostRequest) {
        self.likedList.append(content)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(likedList) {
            defaults.set(encoded, forKey: "LikedContent")
        }
    }
    
    func removeContentList(content: PostRequest) {
        self.likedList.removeAll(where: { $0.title == content.title })
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(likedList) {
            defaults.set(encoded, forKey: "LikedContent")
        }
    }
    
    func getLikedContent() {
        if let likedContent = defaults.object(forKey: "LikedContent") as? Data {
            let decoder = JSONDecoder()
            if let loadedContent = try? decoder.decode([PostRequest].self, from: likedContent) {
                self.likedList = loadedContent
            }
        }
    }
}
