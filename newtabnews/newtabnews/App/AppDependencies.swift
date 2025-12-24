//
//  AppDependencies.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//


import Foundation

/// Container de dependências do app
/// Centraliza a criação e injeção de todas as dependências
class AppDependencies {
    
    static let shared = AppDependencies()
    let contentService: ContentServiceProtocol
        
    init(contentService: ContentServiceProtocol? = nil) {
        // Permite injetar mock para testes, senão usa o real
        self.contentService = contentService ?? ContentService()
    }
    
    // MARK: - Factory Methods
    
    func makeMainViewModel() -> MainViewModel {
        return MainViewModel(service: contentService)
    }
    
    func makeNewsletterViewModel() -> NewsletterViewModel {
        return NewsletterViewModel(service: contentService)
    }
}

// MARK: - Preview Dependencies

extension AppDependencies {
    /// Dependências para previews (usa mock)
    static var preview: AppDependencies {
        return AppDependencies(contentService: MockContentService.success)
    }
    
    /// Dependências para testes (usa mock)
    static func test(service: ContentServiceProtocol) -> AppDependencies {
        return AppDependencies(contentService: service)
    }
}
