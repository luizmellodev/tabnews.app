//
//  KeychainManager.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    private let service = "com.tabnews.app"
    private let sessionTokenKey = "sessionToken"
    private let userDataKey = "userData"
    
    // MARK: - Session Token
    
    func saveSessionToken(_ token: String) -> Bool {
        let data = Data(token.utf8)
        return save(key: sessionTokenKey, data: data)
    }
    
    func getSessionToken() -> String? {
        guard let data = load(key: sessionTokenKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteSessionToken() -> Bool {
        return delete(key: sessionTokenKey)
    }
    
    // MARK: - User Data
    
    func saveUser(_ user: User) -> Bool {
        guard let data = try? JSONEncoder().encode(user) else { return false }
        return save(key: userDataKey, data: data)
    }
    
    func getUser() -> User? {
        guard let data = load(key: userDataKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    func deleteUser() -> Bool {
        return delete(key: userDataKey)
    }
    
    // MARK: - Clear All
    
    func clearAll() -> Bool {
        let tokenDeleted = deleteSessionToken()
        let userDeleted = deleteUser()
        return tokenDeleted && userDeleted
    }
    
    // MARK: - Private Keychain Operations
    
    private func save(key: String, data: Data) -> Bool {
        // Delete old value if exists
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ [KeychainManager] Saved \(key)")
            return true
        } else {
            print("❌ [KeychainManager] Error saving \(key): \(status)")
            return false
        }
    }
    
    private func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            print("✅ [KeychainManager] Loaded \(key)")
            return result as? Data
        } else if status == errSecItemNotFound {
            print("⚠️ [KeychainManager] \(key) not found")
            return nil
        } else {
            print("❌ [KeychainManager] Error loading \(key): \(status)")
            return nil
        }
    }
    
    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            print("✅ [KeychainManager] Deleted \(key)")
            return true
        } else {
            print("❌ [KeychainManager] Error deleting \(key): \(status)")
            return false
        }
    }
}

