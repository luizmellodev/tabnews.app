//
//  MockContentService.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import Foundation

class MockContentService: ContentServiceProtocol {
    
    // MARK: - Mock Data
    
    var shouldFail: Bool = false
    var mockPosts: [PostRequest] = []
    var mockPost: PostRequest?
    
    // MARK: - ContentServiceProtocol
    
    func getContent(page: String, perPage: String, strategy: String) async throws -> [PostRequest] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return mockPosts.isEmpty ? createMockPosts() : mockPosts
    }
    
    func getPost(user: String, slug: String) async throws -> PostRequest {
        if shouldFail {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return mockPost ?? createMockPost(owner: user, slug: slug)
    }
    
    func getNewsletter(page: String, perPage: String, strategy: String) async throws -> [PostRequest] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return mockPosts.isEmpty ? createMockNewsletters() : mockPosts
    }
    
    func getDigest(page: String, perPage: String, strategy: String) async throws -> [PostRequest] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return mockPosts.isEmpty ? createMockDigests() : mockPosts
    }
    
    func getComments(user: String, slug: String) async throws -> [Comment] {
        if shouldFail {
            throw NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        return Comment.mockComments
    }
    
    // MARK: - Mock Helpers
    
    private func createMockPosts() -> [PostRequest] {
        return [
            createMockPost(
                id: "1",
                owner: "usuario1",
                slug: "post-exemplo-1",
                title: "Post de Exemplo 1",
                body: "Este é um post de exemplo para testes."
            ),
            createMockPost(
                id: "2",
                owner: "usuario2",
                slug: "post-exemplo-2",
                title: "Post de Exemplo 2",
                body: "Outro post de exemplo para testes."
            )
        ]
    }
    
    private func createMockNewsletters() -> [PostRequest] {
        return [
            createMockPost(
                id: "newsletter-1",
                owner: "NewsletterOficial",
                slug: "newsletter-exemplo",
                title: "Newsletter Exemplo",
                body: "Esta é uma newsletter de exemplo."
            )
        ]
    }
    
    private func createMockDigests() -> [PostRequest] {
        return [
            createMockPost(
                id: "digest-1",
                owner: "TabNewsDigest",
                slug: "o-melhor-da-semana-no-tabnews-1",
                title: "🔥 O Melhor da Semana no TabNews #1",
                body: "Semana de 21/12 a 27/12\n\nEste é o seu Digest Semanal..."
            )
        ]
    }
    
    private func createMockPost(
        id: String = "mock-id",
        owner: String,
        slug: String,
        title: String = "Mock Post",
        body: String = "Mock body content"
    ) -> PostRequest {
        return PostRequest(
            id: id,
            ownerId: "owner-id",
            parentId: nil,
            slug: slug,
            title: title,
            body: body,
            status: "published",
            type: "content",
            sourceUrl: nil,
            createdAt: "2025-12-24T00:00:00.000Z",
            updatedAt: "2025-12-24T00:00:00.000Z",
            publishedAt: "2025-12-24T00:00:00.000Z",
            deletedAt: nil,
            ownerUsername: owner,
            tabcoins: 10,
            tabcoinsCredit: 10,
            tabcoinsDebit: 0,
            childrenDeepCount: 0
        )
    }
}

// MARK: - Preview Helpers

extension MockContentService {
    /// Mock service com sucesso (para previews)
    static var success: MockContentService {
        let mock = MockContentService()
        mock.shouldFail = false
        return mock
    }
    
    /// Mock service com erro (para previews)
    static var failure: MockContentService {
        let mock = MockContentService()
        mock.shouldFail = true
        return mock
    }
}

