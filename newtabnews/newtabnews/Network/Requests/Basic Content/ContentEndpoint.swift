//
//  ContentEndpoint.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

enum ContentEndpoint: Endpoint {
    
    case basic
    case post(user: String, slug: String)
    case newsletter
    
    var path: String {
        
        switch self {
        case .basic:
            return "/api/v1/contents"
            
        case .post(let user, let slug):
            return "/api/v1/contents/\(user)/\(slug)"
            
        case .newsletter:
            return "/api/v1/contents/NewsletterOficial/"
        }
    }
}
