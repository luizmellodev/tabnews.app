//
//  JSONInterceptor.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

struct JSONInterceptor: RequestInterceptor {
    
    func adapt(request: URLRequest) -> URLRequest {
        var request = request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
