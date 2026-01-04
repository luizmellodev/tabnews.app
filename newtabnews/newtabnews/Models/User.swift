//
//  User.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let notifications: Bool?
    let features: [String]?
    let tabcoins: Int?
    let tabcash: Int?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case notifications
        case features
        case tabcoins
        case tabcash
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Auth Requests

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct SignupRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct SessionResponse: Codable {
    let id: String
    let token: String
    let expiresAt: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case token
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Comment Request

struct CommentRequest: Codable {
    let parentId: String
    let body: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case parentId = "parent_id"
        case body
        case status
    }
}

