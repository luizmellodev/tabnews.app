//
//  RequestBuilder.swift
//  todo-list
//
//  Created by Luiz Mello on 28/11/24.
//

import Foundation

struct RequestBuilder {
    static func buildRequest(
        url: URL?,
        httpMethod: String,
        token: String?,
        parameters: [String: Any]? = nil,
        authentication: String?,
        body: Data? = nil
    ) -> URLRequest? {
        
        guard let apiUrl = url else { return nil }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = httpMethod
        
        if httpMethod == "POST" && url?.path == "/token" {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            if let authentication  {
                request.httpBody = authentication.data(using: .utf8)
            }
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body {
            request.httpBody = body
        } else if let parameters = parameters, httpMethod != "GET" {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
                return nil
            }
            request.httpBody = jsonData
        }
        
        return request
    }
}
