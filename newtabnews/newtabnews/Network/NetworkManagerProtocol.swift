//
//  NetworkManagerProtocol.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/03/25.
//

import Foundation

protocol NetworkManagerProtocol {
    func sendRequest<T: Decodable>(
        _ endpoint: String,
        method: String,
        parameters: [String: Any]?,
        authentication: String?,
        token: String?,
        body: Data?
    ) async throws -> T
}
