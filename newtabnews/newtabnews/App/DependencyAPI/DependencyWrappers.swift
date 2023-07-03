//
//  DependencyWrappers.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

/// Returns the registered class if it exists or the optional value
/// Example: @SafeInjected(opt: Network()) var network: NetworkProtocol
@propertyWrapper
public struct SafeInjected<T> {
    public let factory = DependencyAPI.shared
    let opt: T
    
    /// Safe Injected initializer
    /// - Parameter opt: The model to return if there is no dependency registered for the given protocol
    public init(opt: T) {
        self.opt = opt
    }
    
    public var wrappedValue: T {
        factory.resolve(protocol: T.self, optionalResult: opt)
    }
}

/// Returns the registered class if it exists
/// BE SURE TO REGISTER BEFORE USE THIS ONE
/// Example: @Injected var network: NetworkProtocol
@propertyWrapper
public struct Injected<T> {
    let factory = DependencyAPI.shared
    
    public init() {}
    
    public var wrappedValue: T {
        guard let obj = factory.resolve(protocol: T.self) else {
            fatalError("Unexpectedly found nil while unwrapping an object of type: \(T.self)")
        }
        return obj
    }
}
