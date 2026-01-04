//
//  VoteManager.swift
//  newtabnews
//
//  Created by Luiz Mello on 04/01/26.
//

import Foundation

class VoteManager {
    static let shared = VoteManager()
    
    private let votedContentKey = "votedContentIds"
    
    private init() {}
    
    // Verifica se o usuário já votou neste conteúdo
    func hasVoted(contentId: String) -> Bool {
        let votedIds = getVotedIds()
        return votedIds.contains(contentId)
    }
    
    // Marca um conteúdo como votado
    func markAsVoted(contentId: String) {
        var votedIds = getVotedIds()
        if !votedIds.contains(contentId) {
            votedIds.append(contentId)
            saveVotedIds(votedIds)
        }
    }
    
    // Remove um voto (caso queira permitir desfazer)
    func removeVote(contentId: String) {
        var votedIds = getVotedIds()
        votedIds.removeAll { $0 == contentId }
        saveVotedIds(votedIds)
    }
    
    // Limpa todos os votos (útil ao fazer logout)
    func clearAllVotes() {
        UserDefaults.standard.removeObject(forKey: votedContentKey)
    }
    
    // MARK: - Private
    
    private func getVotedIds() -> [String] {
        return UserDefaults.standard.stringArray(forKey: votedContentKey) ?? []
    }
    
    private func saveVotedIds(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: votedContentKey)
    }
}

