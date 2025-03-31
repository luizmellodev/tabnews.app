//
//  APIError.swift
//  newtabnews
//
//  Created by Luiz Mello on 31/03/25.
//

import Foundation

struct APIError: Codable {
    let name: String
    let message: String
    let action: String
    let statusCode: Int
    let errorId: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case message
        case action
        case statusCode = "status_code"
        case errorId = "error_id"
    }
}
