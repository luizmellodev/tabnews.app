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
    
    func getContent(page: String, perPage: String, strategy: String) async throws -> [PostRequest] {
        do {
            return try await networkManager.sendRequest(
                "/contents",
                method: "GET",
                parameters: [
                    "page": page,
                    "per_page": perPage,
                    "strategy": strategy
                ],
                authentication: nil,
                token: nil,
                body: nil
            ) as [PostRequest]
        } catch {
            Logger.error("Content fetch error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getPost(user: String, slug: String) async throws -> PostRequest {
        do {
            return try await networkManager.sendRequest(
                "/contents/\(user)/\(slug)",
                method: "GET",
                parameters: nil,
                authentication: nil,
                token: nil,
                body: nil
            ) as PostRequest
        } catch {
            Logger.error("Post fetch error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getNewsletter(page: String, perPage: String, strategy: String) async throws -> [PostRequest] {
        do {
            return try await networkManager.sendRequest(
                "/contents/NewsletterOficial",
                method: "GET",
                parameters: [
                    "page": page,
                    "per_page": perPage,
                    "strategy": strategy
                ],
                authentication: nil,
                token: nil,
                body: nil
            ) as [PostRequest]
        } catch {
            Logger.error("Newsletter fetch error: \(error.localizedDescription)")
            throw error
        }
    }
}
