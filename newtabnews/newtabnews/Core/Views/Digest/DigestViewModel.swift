//
//  DigestViewModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/12/25.
//

import Foundation
import SwiftUI

@Observable
class DigestViewModel: ObservableObject {
    private let service: ContentServiceProtocol
    var digests: [PostRequest] = []
    var state: DefaultViewState = .started
    var alreadyLoaded: Bool = false
    
    init(service: ContentServiceProtocol = ContentService()) {
        self.service = service
    }
    
    @MainActor
    func fetchDigestContent() async {
        self.state = .loading
        do {
            self.digests = try await service.getDigest(page: "1", perPage: "20", strategy: "new")
            
            self.state = .requestSucceeded
            self.alreadyLoaded = true
        } catch {
            self.state = .requestFailed
            print(error)
        }
    }
    
    @MainActor
    func fetchDigestPost() async {
        for index in digests.indices {
            do {
                let response = try await service.getPost(
                    user: digests[index].ownerUsername ?? "erro",
                    slug: digests[index].slug ?? "erro"
                )
                digests[index].body = response.body
            } catch {
                // Não mudar o estado geral por erro individual
                // Apenas logar o erro e continuar com as próximas
                print("Erro ao buscar digest [\(digests[index].slug ?? "unknown")]: \(error)")
                // Marcar o body como erro para este item específico
                digests[index].body = "Erro ao carregar conteúdo"
            }
        }
    }
}

