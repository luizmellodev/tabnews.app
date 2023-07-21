//
//  ContentModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public struct ContentRequest: Codable, Hashable, Identifiable {
    public let id, ownerID, mainContent: String?
    let parentID: String?
    let slug, title, status: String?
    let sourceURL: String?
    let createdAt, updatedAt, publishedAt: String?
    let deletedAt: String?
    let ownerUsername: String?
    let tabcoins, childrenDeepCount: Int?
}

extension ContentRequest {
    enum CodingKeys: String, CodingKey {
        case id
        case mainContent
        case ownerID = "owner_id"
        case parentID = "parent_id"
        case slug, title, status
        case sourceURL = "source_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case deletedAt = "deleted_at"
        case ownerUsername = "owner_username"
        case tabcoins
        case childrenDeepCount = "children_deep_count"
    }
}
