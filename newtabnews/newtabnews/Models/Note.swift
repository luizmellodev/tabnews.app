//
//  Note.swift
//  newtabnews
//
//  Created by Luiz Mello on 19/11/25.
//

import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var postId: String // ID do post relacionado
    var postTitle: String? // Título do post
    var content: String // Conteúdo da anotação
    var createdAt: Date
    var updatedAt: Date
    
    init(postId: String, postTitle: String?, content: String) {
        self.id = UUID()
        self.postId = postId
        self.postTitle = postTitle
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateContent(_ newContent: String) {
        self.content = newContent
        self.updatedAt = Date()
    }
}

