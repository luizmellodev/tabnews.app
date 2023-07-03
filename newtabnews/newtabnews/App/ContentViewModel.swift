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

    
    func fetchContent() async {
        let contentResponse = await service.getContent(page: "1", perPage: "5", strategy: "new")
        switch contentResponse {
        case .success(let response):
            DispatchQueue.main.async {
                self.content = response
            }
        case .failure(let error), .customError(let error):
            print(error)
        }
    }
}
