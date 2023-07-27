//
//  MainViewModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import Foundation


class MainViewModel: ObservableObject {
    
    @Injected var service: ContentServiceProtocol
    @Published var content: [ContentRequest] = []
    
    @MainActor
    func fetchContent() async {
        let contentResponse = await service.getContent(page: "1", perPage: "10", strategy: "new")
        switch contentResponse {
        case .success(let response):
            self.content = response
        case .failure(let error), .customError(let error):
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
                print(error)
            }
        }
    }
}

