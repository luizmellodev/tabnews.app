//
//  WidgetPost.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import Foundation

struct WidgetPost: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let ownerUsername: String
    let slug: String
    let tabcoins: Int?
    let createdAt: String
    let body: String?
    
    var url: URL? {
        URL(string: "tabnews://post/\(ownerUsername)/\(slug)")
    }
    
    init(id: String, title: String, ownerUsername: String, slug: String, tabcoins: Int?, createdAt: String, body: String?) {
        self.id = id
        self.title = title
        self.ownerUsername = ownerUsername
        self.slug = slug
        self.tabcoins = tabcoins
        self.createdAt = createdAt
        self.body = body
    }
    
    init?(from postRequest: PostRequest) {
        guard let id = postRequest.id,
              let title = postRequest.title,
              let ownerUsername = postRequest.ownerUsername,
              let slug = postRequest.slug,
              let createdAt = postRequest.createdAt else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.ownerUsername = ownerUsername
        self.slug = slug
        self.tabcoins = postRequest.tabcoins
        self.createdAt = createdAt
        self.body = postRequest.body
    }
    
    static var mockPosts: [WidgetPost] {
        [
            WidgetPost(
                id: "1",
                title: "Como criar widgets incríveis no iOS",
                ownerUsername: "luizmellodev",
                slug: "como-criar-widgets",
                tabcoins: 42,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                body: nil
            ),
            WidgetPost(
                id: "2",
                title: "SwiftUI: Novidades do iOS 18",
                ownerUsername: "filipedeschamps",
                slug: "swiftui-ios-18",
                tabcoins: 35,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                body: nil
            )
        ]
    }
    
    static var mockDigest: WidgetPost {
        WidgetPost(
            id: "digest-1",
            title: "Resumo Semanal #123",
            ownerUsername: "italosousa",
            slug: "resumo-semanal-123",
            tabcoins: 156,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            body: "Os melhores posts da semana..."
        )
    }
}

