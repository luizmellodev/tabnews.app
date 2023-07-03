//
//  ContentEndpoint.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

enum ContentEndpoint: Endpoint {
    
    case basic
    
    var path: String {
        
        switch self {
        case .basic:
            return "/api/v1/contents"
        }
    }
}
