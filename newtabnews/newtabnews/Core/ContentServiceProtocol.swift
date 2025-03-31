import Foundation
import Combine

protocol ContentServiceProtocol {
    func getContent(page: String, perPage: String, strategy: String) async throws -> [ContentRequest]
    func getPost(user: String, slug: String) async throws -> ContentRequest
}