import Foundation

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
        )
    }
    
    func getPost(user: String, slug: String) async throws -> ContentRequest {
        return try await networkManager.sendRequest(
            "/api/v1/contents/\(user)/\(slug)",
            method: "GET",
            parameters: nil,
            authentication: nil,
            token: nil
        )
    }
}