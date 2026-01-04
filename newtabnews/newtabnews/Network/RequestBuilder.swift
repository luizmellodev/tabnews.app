//
//  RequestBuilder.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/03/25.
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
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Adicionar autenticação se fornecida
        if let token = token {
            if let authentication = authentication {
                // Usar o header especificado (ex: "Cookie")
                request.setValue(token, forHTTPHeaderField: authentication)
                print("🔐 [RequestBuilder] Adicionando header \(authentication): \(token)")
            } else {
                // Se não especificar o tipo, usar Authorization Bearer por padrão
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("🔐 [RequestBuilder] Adicionando Authorization Bearer")
            }
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
