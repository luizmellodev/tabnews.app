//
//  Encodable+Extensions.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

public extension Encodable {
    
    func asDictionary() -> [String: Any]? {
        
        @Injected var encoder: JSONEncoder
        
        guard let data = try? encoder.encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        print(dictionary)
        return dictionary
    }
}
