import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
}

class NetworkManager {
    private let baseURL = "https://www.tabnews.com.br/api/v1"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        // Add query parameters for GET requests
        if method == .get, let parameters = parameters {
            urlComponents.queryItems = parameters.map { 
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body for non-GET requests
        if method != .get, let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(NSError(domain: "", code: -1))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}