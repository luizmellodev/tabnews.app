//
//  ContentModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

// MARK: - ContentRequestElement
public struct ContentRequest: Codable, Equatable, Identifiable {
    public let id, ownerID: String?
    let parentID: JSONNull?
    let slug, title, status: String
    let sourceURL: JSONNull?
    let createdAt, updatedAt, publishedAt: String?
    let deletedAt: JSONNull?
    let ownerUsername: String?
    let tabcoins, childrenDeepCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case ownerID
        case parentID
        case slug, title, status
        case sourceURL
        case createdAt
        case updatedAt
        case publishedAt
        case deletedAt
        case ownerUsername
        case tabcoins
        case childrenDeepCount
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
