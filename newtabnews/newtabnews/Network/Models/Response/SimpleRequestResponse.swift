//
//  SimpleRequestResponse.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public enum SimpleRequestResponse<E: Codable & Error> {
    
    case success
    case customError(E)
    case failure(RequestError)
}
