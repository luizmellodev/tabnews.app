//
//  EnvironmentProtocol.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public protocol EnvironmentProtocol: AnyObject {
    
    var infoDictionary: [String: Any] { get }
    
    var baseURL: String { get }
    
    var publicKey: String { get }

    var privateKey: String { get }
}
