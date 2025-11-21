//
//  Highlight.swift
//  newtabnews
//
//  Created by Luiz Mello on 19/11/25.
//

import Foundation
import SwiftData

@Model
final class Highlight {
    var id: UUID
    var postId: String // ID do post
    var postTitle: String? // Título do post (para referência)
    var highlightedText: String // Texto marcado
    var note: String? // Nota pessoal opcional
    var colorHex: String // Cor do highlight (#FFFF00 para amarelo, etc)
    var createdAt: Date
    var rangeStart: Int // Posição inicial no texto
    var rangeLength: Int // Tamanho do trecho marcado
    
    init(
        postId: String,
        postTitle: String?,
        highlightedText: String,
        note: String? = nil,
        colorHex: String = "#FFFF00", // Amarelo por padrão
        rangeStart: Int,
        rangeLength: Int
    ) {
        self.id = UUID()
        self.postId = postId
        self.postTitle = postTitle
        self.highlightedText = highlightedText
        self.note = note
        self.colorHex = colorHex
        self.createdAt = Date()
        self.rangeStart = rangeStart
        self.rangeLength = rangeLength
    }
    
    var hasNote: Bool {
        note != nil && !note!.isEmpty
    }
}

// Cores pré-definidas para highlights
enum HighlightColor: String, CaseIterable {
    case yellow = "#FFFF00"
    case green = "#90EE90"
    case blue = "#87CEEB"
    case pink = "#FFB6C1"
    case orange = "#FFA500"
    
    var displayName: String {
        switch self {
        case .yellow: return "Amarelo"
        case .green: return "Verde"
        case .blue: return "Azul"
        case .pink: return "Rosa"
        case .orange: return "Laranja"
        }
    }
}

