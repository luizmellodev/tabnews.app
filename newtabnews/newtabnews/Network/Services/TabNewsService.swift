import Foundation

class TabNewsService {
    private let network: NetworkManager
    
    init(network: NetworkManager = NetworkManager()) {
        self.network = network
    }
    
    func getContent(page: String, perPage: String, strategy: String) async throws -> [ContentRequest] {
        let parameters = [
            "page": page,
            "per_page": perPage,
            "strategy": strategy
        ]
        
        return try await network.request(
            endpoint: "/contents",
            parameters: parameters
        )
    }
    
    func getNewsletter(page: String, perPage: String, strategy: String) async throws -> [ContentRequest] {
        let parameters = [
            "page": page,
            "per_page": perPage,
            "strategy": strategy
        ]
        
        return try await network.request(
            endpoint: "/contents/newsletter",
            parameters: parameters
        )
    }
    
    func getPost(user: String, slug: String) async throws -> PostRequest {
        return try await network.request(
            endpoint: "/contents/\(user)/\(slug)"
        )
    }
}