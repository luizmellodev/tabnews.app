//
//  AuthService.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import Foundation
import Combine

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case usernameAlreadyExists
    case weakPassword
    case invalidEmail
    case networkError
    case serverError
    case encodingError
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email ou senha incorretos"
        case .userNotFound:
            return "Usuário não encontrado"
        case .emailAlreadyExists:
            return "Este email já está cadastrado"
        case .usernameAlreadyExists:
            return "Este nome de usuário já existe"
        case .weakPassword:
            return "A senha deve ter pelo menos 6 caracteres"
        case .invalidEmail:
            return "Email inválido"
        case .networkError:
            return "Erro de conexão. Verifique sua internet"
        case .serverError:
            return "Erro no servidor. Tente novamente"
        case .encodingError:
            return "Erro ao processar dados"
        case .unauthorized:
            return "Não autorizado. Faça login novamente"
        case .unknown:
            return "Erro desconhecido. Tente novamente"
        }
    }
    
    static func from(_ error: Error) -> AuthError {
        print("🔍 [AuthError] Analisando erro: \(error)")
        
        // Se já é um AuthError, retorna ele mesmo
        if let authError = error as? AuthError {
            return authError
        }
        
        // Verifica se é um NetworkError
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let apiError):
                print("🔍 [AuthError] API Error - Status: \(apiError.statusCode), Message: \(apiError.message)")
                
                // Analisa o status code primeiro
                switch apiError.statusCode {
                case 401:
                    return .invalidCredentials
                case 404:
                    return .userNotFound
                case 409:
                    // Verifica se é email ou username duplicado
                    let message = apiError.message.lowercased()
                    if message.contains("email") {
                        return .emailAlreadyExists
                    } else if message.contains("username") || message.contains("usuário") {
                        return .usernameAlreadyExists
                    }
                    return .emailAlreadyExists
                case 422:
                    let message = apiError.message.lowercased()
                    if message.contains("email") {
                        return .invalidEmail
                    } else if message.contains("password") || message.contains("senha") {
                        return .weakPassword
                    }
                    return .invalidEmail
                default:
                    // Analisa a mensagem da API como fallback
                    let message = apiError.message.lowercased()
                    if message.contains("credentials") || message.contains("password") || message.contains("senha") || message.contains("incorret") {
                        return .invalidCredentials
                    } else if message.contains("email") && message.contains("already") {
                        return .emailAlreadyExists
                    } else if message.contains("username") && message.contains("already") {
                        return .usernameAlreadyExists
                    } else if message.contains("not found") {
                        return .userNotFound
                    }
                    return .serverError
                }
            case .badServerResponse:
                return .serverError
            case .invalidURL:
                return .networkError
            case .decodingError:
                return .serverError
            }
        }
        
        // Verifica o código de erro NSError (para erros de rede)
        let nsError = error as NSError
        print("🔍 [AuthError] NSError - Domain: \(nsError.domain), Code: \(nsError.code)")
        
        switch nsError.code {
        case -1009, -1001: // Sem internet
            return .networkError
        default:
            return .unknown
        }
    }
}

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    private let networkManager: NetworkManagerProtocol
    private let keychainManager = KeychainManager.shared
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
        checkAuthStatus()
    }
    
    // MARK: - Auth Status
    
    func checkAuthStatus() {
        if let token = keychainManager.getSessionToken(),
           let user = keychainManager.getUser() {
            self.isAuthenticated = true
            self.currentUser = user
            print("✅ [AuthService] Usuário autenticado: @\(user.username)")
        } else {
            self.isAuthenticated = false
            self.currentUser = nil
            print("⚠️ [AuthService] Usuário não autenticado")
        }
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async throws {
        print("🔐 [AuthService] Iniciando login para: \(email)")
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        guard let body = try? JSONEncoder().encode(loginRequest) else {
            print("❌ [AuthService] Erro ao codificar dados de login")
            throw AuthError.encodingError
        }
        
        print("📤 [AuthService] Enviando requisição de login...")
        
        do {
            // Login e obter session_id (a API retorna o token no body)
            let response: SessionResponse = try await networkManager.sendRequest(
                "/sessions",
                method: "POST",
                parameters: nil,
                authentication: nil,
                token: nil,
                body: body
            )
            
            print("✅ [AuthService] Resposta recebida - ID: \(response.id)")
            print("🔑 [AuthService] Token recebido: \(response.token.prefix(20))...")
            
            // Salvar token
            let saved = keychainManager.saveSessionToken(response.token)
            print("💾 [AuthService] Token salvo no Keychain: \(saved)")
            
            // Buscar dados do usuário usando o token
            print("👤 [AuthService] Buscando dados do usuário...")
            try await fetchCurrentUser(token: response.token)
            
            await MainActor.run {
                self.isAuthenticated = true
                print("✅ [AuthService] isAuthenticated = true")
            }
            
            print("✅ [AuthService] Login realizado com sucesso!")
        } catch {
            print("❌ [AuthService] Erro no login: \(error)")
            throw AuthError.from(error)
        }
    }
    
    // MARK: - Signup
    
    func signup(username: String, email: String, password: String) async throws {
        let signupRequest = SignupRequest(username: username, email: email, password: password)
        
        guard let body = try? JSONEncoder().encode(signupRequest) else {
            throw AuthError.encodingError
        }
        
        do {
            let _: User = try await networkManager.sendRequest(
                "/users",
                method: "POST",
                parameters: nil,
                authentication: nil,
                token: nil,
                body: body
            )
            
            print("✅ [AuthService] Cadastro realizado com sucesso. Verifique seu email!")
        } catch {
            print("❌ [AuthService] Erro no cadastro: \(error)")
            throw AuthError.from(error)
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        _ = keychainManager.clearAll()
        
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
        }
        
        print("✅ [AuthService] Logout realizado")
    }
    
    // MARK: - Get Current User
    
    private func fetchCurrentUser(token: String) async throws {
        let user: User = try await networkManager.sendRequest(
            "/user",
            method: "GET",
            parameters: nil,
            authentication: nil,
            token: token,
            body: nil
        )
        
        _ = keychainManager.saveUser(user)
        
        await MainActor.run {
            self.currentUser = user
        }
        
        print("✅ [AuthService] Dados do usuário carregados: @\(user.username)")
    }
    
    // MARK: - Post Comment
    
    func postComment(parentId: String, body: String) async throws -> Comment {
        guard let token = keychainManager.getSessionToken() else {
            throw NSError(domain: "AuthService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuário não autenticado"])
        }
        
        let commentRequest = CommentRequest(
            parentId: parentId,
            body: body,
            status: "published"
        )
        
        guard let requestBody = try? JSONEncoder().encode(commentRequest) else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao codificar comentário"])
        }
        
        let comment: Comment = try await networkManager.sendRequest(
            "/contents",
            method: "POST",
            parameters: nil,
            authentication: "Cookie",
            token: "session_id=\(token)",
            body: requestBody
        )
        
        print("✅ [AuthService] Comentário publicado com sucesso")
        return comment
    }
    
    // MARK: - Vote on Content (Upvote/Downvote)
    
    func voteOnContent(username: String, slug: String, transactionType: String) async throws {
        guard let token = keychainManager.getSessionToken() else {
            throw AuthError.unauthorized
        }
        
        print("🗳️ [AuthService] Token obtido: \(token.prefix(20))...")
        
        // Criar JSON manualmente para garantir formato correto
        let jsonString = "{\"transaction_type\":\"\(transactionType)\"}"
        guard let requestBody = jsonString.data(using: .utf8) else {
            throw AuthError.encodingError
        }
        
        print("🗳️ [AuthService] Tentando votar: \(transactionType) em \(username)/\(slug)")
        print("📦 [AuthService] Body: \(jsonString)")
        print("🍪 [AuthService] Cookie que será enviado: session_id=\(token.prefix(20))...")
        
        // Endpoint: POST /contents/{username}/{slug}/tabcoins
        // A resposta é o próprio comentário atualizado
        let _: Comment = try await networkManager.sendRequest(
            "/contents/\(username)/\(slug)/tabcoins",
            method: "POST",
            parameters: nil,
            authentication: "Cookie",
            token: "session_id=\(token)",
            body: requestBody
        )
        
        print("✅ [AuthService] Voto registrado: \(transactionType) em \(username)/\(slug)")
    }
}

