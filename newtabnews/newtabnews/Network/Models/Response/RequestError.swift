//
//  RequestError.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public struct RequestError: Codable, Error, Equatable {
    
    var statusCode: Int
    var errorMessage: String
}

// MARK: Static Helpers
extension RequestError {

    static let internalError = RequestError(statusCode: 400,
                                            errorMessage: "network.internalError")
    static let noConnectionError = RequestError(statusCode: 503,
                                                errorMessage: "network.noInternetConnection")
}
