//
//  ContentServiceProtocol.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/03/25.
//

import Foundation

protocol ContentServiceProtocol {
    func getContent(page: String, perPage: String, strategy: String) async throws -> [PostRequest]
    func getPost(user: String, slug: String) async throws -> PostRequest
    func getNewsletter(page: String, perPage: String, strategy: String) async throws -> [PostRequest]
    func getDigest(page: String, perPage: String, strategy: String) async throws -> [PostRequest]
    func getComments(user: String, slug: String) async throws -> [Comment]
}
