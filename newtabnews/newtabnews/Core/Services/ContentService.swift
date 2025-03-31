//
//  ContentService.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/03/25.
//


import Foundation
import Combine

class ContentService: ContentServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func getContent(page: String, perPage: String, strategy: String) async throws -> [ContentRequest] {
        return try await networkManager.sendRequest(
            "/api/v1/contents",
            method: "GET",
            parameters: [
                "page": page,
                "per_page": perPage,
                "strategy": strategy
            ],
            authentication: nil,
            token: nil
        ).async()
    }
    
    func getPost(user: String, slug: String) async throws -> ContentRequest {
        return try await networkManager.sendRequest(
            "/api/v1/contents/\(user)/\(slug)",
            method: "GET",
            authentication: nil,
            token: nil
        ).async()
    }
}
