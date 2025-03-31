import Foundation

enum NetworkError: Error {
    case invalidURL
    case badServerResponse
    case decodingError
    case encodingError
    case unknown(Error)
}
