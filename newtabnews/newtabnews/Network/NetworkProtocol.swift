//
//  NetworkProtocol.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public protocol NetworkProtocol: AnyObject {
    
    func request<R: Decodable,
                 E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: Codable?,
                               interceptors: [RequestInterceptor],
                               responseType: R.Type,
                               errorType: E.Type) async -> RequestResponse<R, E>
    
    func request<R: Decodable,
                 E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: [String: Any],
                               interceptors: [RequestInterceptor],
                               responseType: R.Type,
                               errorType: E.Type) async -> RequestResponse<R, E>
    
    func request<E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: Codable?,
                               interceptors: [RequestInterceptor],
                               errorType: E.Type) async -> SimpleRequestResponse<E>
    
    func request<E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: [String: Any],
                               interceptors: [RequestInterceptor],
                               errorType: E.Type) async -> SimpleRequestResponse<E>
}
