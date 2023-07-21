//
//  ContentViewModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation


class ContentViewModel: ObservableObject {
    
    @Injected var service: ContentServiceProtocol
    @Published var content: [ContentRequest] = []
    @Published var post: String = ""
    
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
    func fetchPost(user: String, slug: String) async {
        let postResponse = await service.getPost(user: user, slug: slug)
        switch postResponse {
        case .success(let response):
            self.post = response.mainContent ?? ""
        case .failure(let error), .customError(let error):
            print(error)
        }
    }
}
