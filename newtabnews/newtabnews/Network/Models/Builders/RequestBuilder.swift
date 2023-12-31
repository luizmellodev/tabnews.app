//
//  RequestBuilder.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

class RequestBuilder {
    
    let queryBuilder: QueryBuilder
    let bodyBuilder: BodyBuilder
    let interceptorBuilder: InterceptorBuilder
    
    init(queryBuilder: QueryBuilder = QueryBuilder(),
         bodyBuilder: BodyBuilder = BodyBuilder(),
         interceptorBuilder: InterceptorBuilder = InterceptorBuilder()) {
        self.queryBuilder = queryBuilder
        self.bodyBuilder = bodyBuilder
        self.interceptorBuilder = interceptorBuilder
    }
}

// MARK: - Methods
extension RequestBuilder {
    
    func makeRequest(host: String,
                     path: String,
                     method: HTTPMethod,
                     parameters: Codable?,
                     interceptors: [RequestInterceptor]) async -> URLRequest? {
    
        return await makeRequest(host: host,
                           path: path,
                           method: method,
                           parameters: parameters?.asDictionary() ?? [:],
                           interceptors: interceptors)
    }
    
    func makeRequest(host: String,
                     path: String,
                     method: HTTPMethod,
                     parameters: [String: Any],
                     interceptors: [RequestInterceptor]) async -> URLRequest? {
        
        var urlComponents = URLComponents(string: host) ?? URLComponents()
        urlComponents.path = path
        
        if method.shouldUseQuery {
            print(parameters)
            urlComponents.queryItems = queryBuilder.build(parameters: parameters)
        }
        
        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method.shouldUseBody {
            request.httpBody = bodyBuilder.build(parameters: parameters)
            print("AQUI CARALHO \(String(describing: request.httpBody))")

        }
        
        request = await interceptorBuilder.adapt(urlRequest: request, interceptors: interceptors)
        
        return request
    }
}
