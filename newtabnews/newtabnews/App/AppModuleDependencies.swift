//
//  AppModuleDependencies.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import Foundation

// MARK: - ModuleDependencies
class AppModuleDependencies {
    
    let factory = DependencyAPI.shared
    
    // MARK: - Stored Properties
    var encoder: JSONEncoder
    var decoder: JSONDecoder
    var environment: Environment?
    
    // MARK: - Initializers
    init(encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder(),
         environment: Environment? = nil) {
        self.encoder = encoder
        self.decoder = decoder
        self.environment = environment
    }
    
    func setupDependencies() {
        setupEncoder()
        setupDecoder()
        
        setupEnvironment()
        setupNetwork()
    }
}

private extension AppModuleDependencies {
    func setupEncoder() {
        factory.register(encoder, as: JSONEncoder.self)
    }
    
    func setupDecoder() {
        factory.register(decoder, as: JSONDecoder.self)
    }
    
    func setupEnvironment() {
        factory.register(Environment(), as: EnvironmentProtocol.self)
    }
    
    func setupNetwork() {
        factory.register(Network(), as: NetworkProtocol.self)
        factory.register(ContentService(), as: ContentServiceProtocol.self)
    }
}
