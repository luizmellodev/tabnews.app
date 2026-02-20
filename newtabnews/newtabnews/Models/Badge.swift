//
//  Badge.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/02/26.
//

import Foundation
import SwiftUI

enum BadgeType: String, Codable, CaseIterable {
    // Reading badges
    case firstRead = "first_read"
    case reader5 = "reader_5"
    case reader10 = "reader_10"
    case reader25 = "reader_25"
    case reader50 = "reader_50"
    case reader100 = "reader_100"
    case reader250 = "reader_250"
    case reader500 = "reader_500"
    
    // Engagement badges
    case firstComment = "first_comment"
    case commenter5 = "commenter_5"
    case commenter10 = "commenter_10"
    case commenter25 = "commenter_25"
    case commenter50 = "commenter_50"
    
    // Like badges
    case firstLike = "first_like"
    case curator10 = "curator_10"
    case curator25 = "curator_25"
    case curator50 = "curator_50"
    case curator100 = "curator_100"
    
    // Highlight badges
    case firstHighlight = "first_highlight"
    case highlighter10 = "highlighter_10"
    case highlighter25 = "highlighter_25"
    case highlighter50 = "highlighter_50"
    
    // Note badges
    case firstNote = "first_note"
    case writer5 = "writer_5"
    case writer10 = "writer_10"
    case writer25 = "writer_25"
    
    // Organization badges
    case firstFolder = "first_folder"
    case organizer5 = "organizer_5"
    case organizer10 = "organizer_10"
    
    // Streak badges
    case weeklyStreak3 = "weekly_streak_3"
    case weeklyStreak5 = "weekly_streak_5"
    case weeklyStreak10 = "weekly_streak_10"
    case weeklyStreak20 = "weekly_streak_20"
    
    // Time-based badges
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case weekendReader = "weekend_reader"
    case weekendWarrior = "weekend_warrior"
    
    // Special badges
    case speedReader = "speed_reader"
    case perfectWeek = "perfect_week"
    case socialButterfly = "social_butterfly"
    case knowledgeSeeker = "knowledge_seeker"
    case masterCurator = "master_curator"
    
    var title: String {
        switch self {
        case .firstRead: return "Primeira Leitura"
        case .reader5: return "Leitor Iniciante"
        case .reader10: return "Leitor Curioso"
        case .reader25: return "Leitor Dedicado"
        case .reader50: return "Leitor Ávido"
        case .reader100: return "Leitor Expert"
        case .reader250: return "Leitor Master"
        case .reader500: return "Leitor Lendário"
        case .firstComment: return "Primeira Voz"
        case .commenter5: return "Conversador"
        case .commenter10: return "Debatedor"
        case .commenter25: return "Comunicador"
        case .commenter50: return "Influenciador"
        case .firstLike: return "Primeira Curtida"
        case .curator10: return "Curador"
        case .curator25: return "Curador Expert"
        case .curator50: return "Curador Master"
        case .curator100: return "Curador Lendário"
        case .firstHighlight: return "Primeiro Destaque"
        case .highlighter10: return "Marcador"
        case .highlighter25: return "Destacador"
        case .highlighter50: return "Marcador Expert"
        case .firstNote: return "Primeira Anotação"
        case .writer5: return "Escritor"
        case .writer10: return "Anotador"
        case .writer25: return "Documentador"
        case .firstFolder: return "Organizador"
        case .organizer5: return "Arquivista"
        case .organizer10: return "Bibliotecário"
        case .weeklyStreak3: return "Consistente"
        case .weeklyStreak5: return "Dedicado"
        case .weeklyStreak10: return "Compromissado"
        case .weeklyStreak20: return "Lendário"
        case .earlyBird: return "Madrugador"
        case .nightOwl: return "Coruja Noturna"
        case .weekendReader: return "Leitor de Fim de Semana"
        case .weekendWarrior: return "Guerreiro do Fim de Semana"
        case .speedReader: return "Leitor Veloz"
        case .perfectWeek: return "Semana Perfeita"
        case .socialButterfly: return "Social"
        case .knowledgeSeeker: return "Buscador de Conhecimento"
        case .masterCurator: return "Curador Master"
        }
    }
    
    var description: String {
        switch self {
        case .firstRead: return "Leu seu primeiro post"
        case .reader5: return "Leu 5 posts"
        case .reader10: return "Leu 10 posts"
        case .reader25: return "Leu 25 posts"
        case .reader50: return "Leu 50 posts"
        case .reader100: return "Leu 100 posts"
        case .reader250: return "Leu 250 posts"
        case .reader500: return "Leu 500 posts"
        case .firstComment: return "Fez seu primeiro comentário"
        case .commenter5: return "Fez 5 comentários"
        case .commenter10: return "Fez 10 comentários"
        case .commenter25: return "Fez 25 comentários"
        case .commenter50: return "Fez 50 comentários"
        case .firstLike: return "Curtiu seu primeiro post"
        case .curator10: return "Curtiu 10 posts"
        case .curator25: return "Curtiu 25 posts"
        case .curator50: return "Curtiu 50 posts"
        case .curator100: return "Curtiu 100 posts"
        case .firstHighlight: return "Fez seu primeiro destaque"
        case .highlighter10: return "Fez 10 destaques"
        case .highlighter25: return "Fez 25 destaques"
        case .highlighter50: return "Fez 50 destaques"
        case .firstNote: return "Fez sua primeira anotação"
        case .writer5: return "Fez 5 anotações"
        case .writer10: return "Fez 10 anotações"
        case .writer25: return "Fez 25 anotações"
        case .firstFolder: return "Criou sua primeira pasta"
        case .organizer5: return "Criou 5 pastas"
        case .organizer10: return "Criou 10 pastas"
        case .weeklyStreak3: return "Visitou por 3 semanas seguidas"
        case .weeklyStreak5: return "Visitou por 5 semanas seguidas"
        case .weeklyStreak10: return "Visitou por 10 semanas seguidas"
        case .weeklyStreak20: return "Visitou por 20 semanas seguidas"
        case .earlyBird: return "Leu um post antes das 7h"
        case .nightOwl: return "Leu um post depois das 23h"
        case .weekendReader: return "Leu posts em 5 fins de semana"
        case .weekendWarrior: return "Leu posts em 10 fins de semana"
        case .speedReader: return "Leu 10 posts em um dia"
        case .perfectWeek: return "Completou todos desafios da semana"
        case .socialButterfly: return "Curtiu e comentou 20 vezes"
        case .knowledgeSeeker: return "Leu, destacou e anotou em 10 posts"
        case .masterCurator: return "Organizou 50 posts em pastas"
        }
    }
    
    var icon: String {
        switch self {
        case .firstRead: return "book.fill"
        case .reader5, .reader10: return "books.vertical.fill"
        case .reader25, .reader50: return "text.book.closed.fill"
        case .reader100, .reader250: return "graduationcap.fill"
        case .reader500: return "crown.fill"
        case .firstComment, .commenter5: return "bubble.left.and.bubble.right.fill"
        case .commenter10, .commenter25: return "person.wave.2.fill"
        case .commenter50: return "megaphone.fill"
        case .firstLike, .curator10: return "heart.fill"
        case .curator25, .curator50: return "star.fill"
        case .curator100: return "crown.fill"
        case .firstHighlight, .highlighter10: return "highlighter"
        case .highlighter25, .highlighter50: return "paintbrush.fill"
        case .firstNote, .writer5: return "note.text"
        case .writer10, .writer25: return "pencil.and.list.clipboard"
        case .firstFolder, .organizer5: return "folder.fill"
        case .organizer10: return "archivebox.fill"
        case .weeklyStreak3, .weeklyStreak5: return "flame.fill"
        case .weeklyStreak10: return "sparkles"
        case .weeklyStreak20: return "trophy.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .weekendReader: return "beach.umbrella.fill"
        case .weekendWarrior: return "figure.surfing"
        case .speedReader: return "bolt.fill"
        case .perfectWeek: return "checkmark.seal.fill"
        case .socialButterfly: return "person.3.fill"
        case .knowledgeSeeker: return "brain.head.profile"
        case .masterCurator: return "star.leadinghalf.filled"
        }
    }
    
    var color: Color {
        switch self {
        case .firstRead, .reader5: return .blue
        case .reader10, .reader25: return .purple
        case .reader50, .reader100: return .orange
        case .reader250: return .red
        case .reader500: return .yellow
        case .firstComment, .commenter5: return .green
        case .commenter10, .commenter25: return .teal
        case .commenter50: return .mint
        case .firstLike, .curator10: return .pink
        case .curator25, .curator50: return .red
        case .curator100: return .yellow
        case .firstHighlight, .highlighter10: return .yellow
        case .highlighter25, .highlighter50: return .orange
        case .firstNote, .writer5: return .orange
        case .writer10, .writer25: return .brown
        case .firstFolder, .organizer5: return .indigo
        case .organizer10: return .purple
        case .weeklyStreak3: return .red
        case .weeklyStreak5: return .orange
        case .weeklyStreak10: return .pink
        case .weeklyStreak20: return .yellow
        case .earlyBird: return .orange
        case .nightOwl: return .indigo
        case .weekendReader: return .cyan
        case .weekendWarrior: return .blue
        case .speedReader: return .yellow
        case .perfectWeek: return .green
        case .socialButterfly: return .pink
        case .knowledgeSeeker: return .purple
        case .masterCurator: return .yellow
        }
    }
    
    var requirement: Int {
        switch self {
        case .firstRead: return 1
        case .reader5: return 5
        case .reader10: return 10
        case .reader25: return 25
        case .reader50: return 50
        case .reader100: return 100
        case .reader250: return 250
        case .reader500: return 500
        case .firstComment: return 1
        case .commenter5: return 5
        case .commenter10: return 10
        case .commenter25: return 25
        case .commenter50: return 50
        case .firstLike: return 1
        case .curator10: return 10
        case .curator25: return 25
        case .curator50: return 50
        case .curator100: return 100
        case .firstHighlight: return 1
        case .highlighter10: return 10
        case .highlighter25: return 25
        case .highlighter50: return 50
        case .firstNote: return 1
        case .writer5: return 5
        case .writer10: return 10
        case .writer25: return 25
        case .firstFolder: return 1
        case .organizer5: return 5
        case .organizer10: return 10
        case .weeklyStreak3: return 3
        case .weeklyStreak5: return 5
        case .weeklyStreak10: return 10
        case .weeklyStreak20: return 20
        case .earlyBird, .nightOwl: return 1
        case .weekendReader: return 5
        case .weekendWarrior: return 10
        case .speedReader: return 10
        case .perfectWeek: return 1
        case .socialButterfly: return 20
        case .knowledgeSeeker: return 10
        case .masterCurator: return 50
        }
    }
}

struct Badge: Identifiable, Codable, Equatable {
    let id: UUID
    let type: BadgeType
    let unlockedAt: Date
    
    init(type: BadgeType, unlockedAt: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.unlockedAt = unlockedAt
    }
}
