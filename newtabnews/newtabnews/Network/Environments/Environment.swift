//
//  Environment.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public class Environment: EnvironmentProtocol {
    
    public init() {}
    
    public var infoDictionary: [String: Any] {
        return Bundle.main.infoDictionary ?? [:]
    }
    
    public var baseURL: String {
        return "https://www.tabnews.com.br/api/v1"
    }
    
    public var publicKey: String {
        return infoDictionary["PUBLIC_KEY"] as? String ?? ""
    }
    
    public var privateKey: String {
        return infoDictionary["PRIVATE_KEY"] as? String ?? ""
    }
}
