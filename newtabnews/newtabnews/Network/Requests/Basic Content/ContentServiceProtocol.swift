//
//  ContentServiceProtocol.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation


public protocol ContentServiceProtocol: AnyObject {
    
    func getContent(page: String, perPage: String, strategy: String) async -> RequestResponse<[ContentRequest], RequestError>
    
    func getNewsletter(page: String, perPage: String, strategy: String) async -> RequestResponse<[ContentRequest], RequestError>
    
    func getPost(user: String, slug: String) async -> RequestResponse<PostRequest, RequestError>
    
}
