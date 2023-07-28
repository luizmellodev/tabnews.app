//
//  MainViewModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import Foundation


class MainViewModel: ObservableObject {
    
    @Injected var service: ContentServiceProtocol
    @Published var likedList: [ContentRequest] = []
    @Published var content: [ContentRequest] = []
    @Published var state: DefaultViewState = .started
    
    let defaults = UserDefaults.standard

    @MainActor
    func fetchContent() async {
        self.state = .loading
        let contentResponse = await service.getContent(page: "1", perPage: "30", strategy: "relevant")
        switch contentResponse {
        case .success(let response):
            self.state = .requestSucceeded
            self.content = response
        case .failure(let error), .customError(let error):
            self.state = .requestFailed
            print(error)
        }
    }
    
    @MainActor
    func fetchPost() async {
        for index in content.indices {
            let postResponse = await service.getPost(user: content[index].ownerUsername ?? "erro", slug: content[index].slug ?? "erro")
            switch postResponse {
            case .success(let response):
                content[index].entirePost = response.body
            case .failure(let error), .customError(let error):
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
    
    func likeContentList(content: ContentRequest) {
        self.likedList.append(content)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(likedList) {
            defaults.set(encoded, forKey: "LikedContent")
        }
    }
    
    func removeContentList(content: ContentRequest) {
        self.likedList.removeAll(where: { $0.title == content.title })
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(likedList) {
            defaults.set(encoded, forKey: "LikedContent")
        }
    }
    
    func getLikedContent() {
        if let likedContent = defaults.object(forKey: "LikedContent") as? Data {
            let decoder = JSONDecoder()
            if let loadedContent = try? decoder.decode([ContentRequest].self, from: likedContent) {
                self.likedList = loadedContent
            }
        }
    }
}

