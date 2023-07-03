//
//  Network.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation


public class Network: NetworkProtocol {
    
    // MARK: - Dependencies
    @Injected var environment: EnvironmentProtocol
    
    // MARK: - Stored Properties
    private let requestBuilder = RequestBuilder()
    
    let session = URLSession.shared
    
    // MARK: - Computed Properties
    var defaultInterceptors: [RequestInterceptor] {
        [JSONInterceptor()]
    }
    
    // MARK: - Initializers
    public init() {}
}

// MARK: - Request Response
public extension Network {
    
    func request<R: Decodable,
                 E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: Codable?,
                               interceptors: [RequestInterceptor],
                               responseType: R.Type,
                               errorType: E.Type) async -> RequestResponse<R, E> {
        
        return await request(endpoint: endpoint,
                             method: method,
                             parameters: parameters?.asDictionary() ?? [:],
                             interceptors: interceptors,
                             responseType: responseType,
                             errorType: errorType)
    }
    
    func request<R: Decodable,
                 E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: [String: Any],
                               interceptors: [RequestInterceptor],
                               responseType: R.Type,
                               errorType: E.Type) async -> RequestResponse<R, E> {
        
        let result = await doRequest(endpoint: endpoint,
                                     method: method,
                                     parameters: parameters,
                                     interceptors: defaultInterceptors + interceptors)
        
        switch result {
        case .success(let response):
            return serializeResponse(response: response,
                                     responseType: responseType,
                                     errorType: errorType)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Simple Request Response
public extension Network {
    
    func request<E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: Codable?,
                               interceptors: [RequestInterceptor],
                               errorType: E.Type) async -> SimpleRequestResponse<E> {
        
        return await request(endpoint: endpoint,
                             method: method,
                             parameters: parameters?.asDictionary() ?? [:],
                             interceptors: interceptors,
                             errorType: errorType)
    }
    
    func request<E: Decodable>(endpoint: Endpoint,
                               method: HTTPMethod,
                               parameters: [String: Any],
                               interceptors: [RequestInterceptor],
                               errorType: E.Type) async -> SimpleRequestResponse<E> {
        
        let result = await doRequest(endpoint: endpoint,
                                     method: method,
                                     parameters: parameters,
                                     interceptors: defaultInterceptors + interceptors)
        
        switch result {
        case .success(let response):
            return serializeResponse(response: response,
                                     errorType: errorType)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Private Methods
extension Network {
    
    private func doRequest(endpoint: Endpoint,
                           method: HTTPMethod,
                           parameters: [String: Any],
                           interceptors: [RequestInterceptor]) async -> Result<RestResponse, RequestError> {
        
        guard let urlRequest = await requestBuilder.makeRequest(host: environment.baseURL,
                                                                path: endpoint.path,
                                                                method: method,
                                                                parameters: parameters,
                                                                interceptors: interceptors) else {
            return .failure(.internalError)
        }
        
        var dataTask: (data: Data, urlResponse: URLResponse)!
        
        do {
            dataTask = try await session.data(for: urlRequest)
        } catch let error {
            if let error = error as? URLError,
                error.errorCode == NSURLErrorNotConnectedToInternet {
                return .failure(.noConnectionError)
            } else {
                return .failure(.internalError)
            }
        }
        
        return .success(RestResponse(request: urlRequest,
                                     dataTask: dataTask))
    }
    
    private func serializeResponse<T: Decodable,
                                   E: Codable & Error>(response: RestResponse,
                                                       responseType: T.Type,
                                                       errorType: E.Type) -> RequestResponse<T, E> {
#if DEBUG
        NetworkLogger.log(response: response)
#endif
        
        let result = response.result(modelType: responseType, errorType: errorType)
        
        switch result {
        case .success(let response):
            return .success(response as! T)
        case .failure(let error):
            print(error)
            switch error {
            case is E:
                return .customError(error as! E)
            case is RequestError:
                return .failure(error as! RequestError)
            default:
                return .failure(RequestError(statusCode: response.statusCode, errorMessage: error.localizedDescription))
            }
        }
    }
    
    private func serializeResponse<E: Codable & Error>(response: RestResponse,
                                                       errorType: E.Type) -> SimpleRequestResponse<E> {
#if DEBUG
        NetworkLogger.log(response: response)
#endif
        
        let result = response.result(errorType: errorType)
        
        switch result {
        case .success:
            return .success
        case .failure(let error):
            
            switch error {
            case is E:
                return .customError(error as! E)
            case is RequestError:
                return .failure(error as! RequestError)
            default:
                return .failure(RequestError(statusCode: response.statusCode, errorMessage: error.localizedDescription))
            }
        }
    }
}
