//
//  InterceptorBuilder.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

class InterceptorBuilder {
    
    func adapt(urlRequest: URLRequest, interceptors: [RequestInterceptor]) async -> URLRequest {
        
        var urlRequest = urlRequest
        
        for index in 0..<interceptors.count {
            urlRequest = await interceptors[index].adapt(request: urlRequest)
        }
        return urlRequest
    }
}
