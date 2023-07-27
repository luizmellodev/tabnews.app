//
//  ContentService.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public class ContentService {
    
    @Injected var network: NetworkProtocol
    
    public init() {}
}

extension ContentService {
    private func contentParameters(page: String, perPage: String, strategy: String) -> [String: Any] {
        return [
            "page": "\(page)",
            "per_page": "\(perPage)",
            "strategy": "\(strategy)"
        ]
    }
}

extension ContentService: ContentServiceProtocol {
    public func getPost(user: String, slug: String) async -> RequestResponse<PostRequest, RequestError> {
        return await network.request(endpoint: ContentEndpoint.post(user: user, slug: slug),
                                     method: .get,
                                     parameters: "",
                                     interceptors: [ContentInterceptor()],
                                     responseType: PostRequest.self,
                                     errorType: RequestError.self)
    }
    
    public func getContent(page: String, perPage: String, strategy: String) async -> RequestResponse<[ContentRequest], RequestError> {
        return await network.request(endpoint: ContentEndpoint.basic,
                                     method: .get,
                                     parameters: contentParameters(page: page, perPage: perPage, strategy: strategy),
                                     interceptors: [ContentInterceptor()],
                                     responseType: [ContentRequest].self,
                                     errorType: RequestError.self)
    }
}
