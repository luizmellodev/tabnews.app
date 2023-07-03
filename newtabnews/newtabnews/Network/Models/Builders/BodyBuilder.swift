//
//  BodyBuilder.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

class BodyBuilder {
    
    func build(parameters: Codable) -> Data? {
        guard let dict = parameters.asDictionary() else { return nil }
        return build(parameters: dict)
    }
    
    func build(parameters: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    }
}
