//
//  RequestInterceptor.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public protocol RequestInterceptor {
    
    func adapt(request: URLRequest) async -> URLRequest
}
