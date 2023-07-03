//
//  RequestResponse.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public enum RequestResponse<D: Codable, E: Codable & Error> {
    
    case success(D)
    case customError(E)
    case failure(RequestError)
}
