//
//  ContentInterceptor.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

struct ContentInterceptor: RequestInterceptor {
    func adapt(request: URLRequest) async -> URLRequest {
        return request
    }
}
