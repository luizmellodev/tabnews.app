import Foundation

class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    let baseURL = URL(string: "https://www.tabnews.com.br/api/v1")!
    
    private init() {}
    
    func sendRequest<T: Decodable>(
        _ endpoint: String,
        method: String,
        parameters: [String: Any]? = nil,
        authentication: String?,
        token: String?,
        body: Data? = nil
    ) async throws -> T {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true)
        
        if let parameters = parameters {
            urlComponents?.queryItems = parameters.map { 
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let url = urlComponents?.url else {
            Logger.error("Invalid URL for endpoint: \(endpoint)")
            throw NetworkError.invalidURL
        }
        
        guard let request = RequestBuilder.buildRequest(
            url: url,
            httpMethod: method,
            token: token,
            parameters: parameters,
            authentication: authentication,
            body: body
        ) else {
            Logger.error("Failed to build request for endpoint: \(endpoint)")
            throw NetworkError.badServerResponse
        }
        
        Logger.info("📤 Sending request to: \(url)")
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            Logger.info("📄 Request body: \(bodyString)")
        }
        
        Logger.info("🔑 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.error("Invalid response type")
            throw NetworkError.badServerResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            Logger.error("⚠️ Error: Bad server response (status code: \(httpResponse.statusCode))")
            Logger.error("Error body: \(errorBody)")
            
            if let errorResponse = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NetworkError.apiError(errorResponse)
            }
            throw NetworkError.badServerResponse
        }
        
        Logger.prettyPrintJSON(from: data)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            Logger.error("❌ Error decoding \(T.self): \(error)")
            throw NetworkError.decodingError
        }
    }
}
