//
//  Comment.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import Foundation

struct Comment: Codable, Identifiable, Hashable {
    let id: String?
    let ownerUsername: String?
    let ownerID: String?
    let slug: String?
    let title: String?
    let body: String?
    let status: String?
    let sourceURL: String?
    let createdAt: String?
    let updatedAt: String?
    let publishedAt: String?
    let deletedAt: String?
    let tabcoins: Int?
    let tabcoinsCredit: Int?
    let tabcoinsDebit: Int?
    let childrenDeepCount: Int?
    let parentID: String?
    var children: [Comment]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerUsername = "owner_username"
        case ownerID = "owner_id"
        case slug
        case title
        case body
        case status
        case sourceURL = "source_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case deletedAt = "deleted_at"
        case tabcoins
        case tabcoinsCredit = "tabcoins_credit"
        case tabcoinsDebit = "tabcoins_debit"
        case childrenDeepCount = "children_deep_count"
        case parentID = "parent_id"
        case children
    }
    
    // Helper para formatar data
    var formattedDate: String {
        guard let createdAt = createdAt else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: createdAt) else {
            return createdAt
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        let months = Int(timeInterval / 2592000)
        let years = Int(timeInterval / 31536000)
        
        if years > 0 {
            return years == 1 ? "há 1 ano" : "há \(years) anos"
        } else if months > 0 {
            return months == 1 ? "há 1 mês" : "há \(months) meses"
        } else if days > 0 {
            return days == 1 ? "há 1 dia" : "há \(days) dias"
        } else if hours > 0 {
            return hours == 1 ? "há 1 hora" : "há \(hours) horas"
        } else if minutes > 0 {
            return minutes == 1 ? "há 1 minuto" : "há \(minutes) minutos"
        } else {
            return "agora"
        }
    }
    
    // Mock para preview
    static var mockComment: Comment {
        Comment(
            id: "1",
            ownerUsername: "luizmellodev",
            ownerID: "user-123",
            slug: "comentario-teste",
            title: nil,
            body: "Este é um comentário de exemplo para testar a interface!",
            status: "published",
            sourceURL: nil,
            createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
            updatedAt: nil,
            publishedAt: nil,
            deletedAt: nil,
            tabcoins: 5,
            tabcoinsCredit: 5,
            tabcoinsDebit: 0,
            childrenDeepCount: 2,
            parentID: "post-123",
            children: [
                Comment(
                    id: "2",
                    ownerUsername: "filipedeschamps",
                    ownerID: "user-456",
                    slug: "resposta-1",
                    title: nil,
                    body: "Concordo! Muito bom mesmo.",
                    status: "published",
                    sourceURL: nil,
                    createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-1800)),
                    updatedAt: nil,
                    publishedAt: nil,
                    deletedAt: nil,
                    tabcoins: 3,
                    tabcoinsCredit: 3,
                    tabcoinsDebit: 0,
                    childrenDeepCount: 0,
                    parentID: "1",
                    children: nil
                )
            ]
        )
    }
    
    static var mockComments: [Comment] {
        [
            mockComment,
            Comment(
                id: "3",
                ownerUsername: "devzito",
                ownerID: "user-789",
                slug: "outro-comentario",
                title: nil,
                body: "Excelente post! Aprendi muito com isso. 🚀",
                status: "published",
                sourceURL: nil,
                createdAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7200)),
                updatedAt: nil,
                publishedAt: nil,
                deletedAt: nil,
                tabcoins: 8,
                tabcoinsCredit: 9,
                tabcoinsDebit: 1,
                childrenDeepCount: 0,
                parentID: "post-123",
                children: nil
            )
        ]
    }
}

