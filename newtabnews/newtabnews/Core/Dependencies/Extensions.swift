//
//  Extensions.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import Foundation
import SwiftUI

public func getFormattedDate(value: String) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "pt_br")
    dateFormat.dateFormat = "EEEE, dd MMMM"
    let stringDate = dateFormat.string(from: Date())
    return stringDate
}

extension String {
    var readingTimeInMinutes: Int {
        let wordsPerMinute = 200 // Velocidade média de leitura em português
        let words = self.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let wordCount = words.count
        return max(1, wordCount / wordsPerMinute)
    }
    
    var readingTimeFormatted: String {
        let minutes = readingTimeInMinutes
        if minutes < 1 {
            return "< 1 min"
        } else if minutes == 1 {
            return "1 min"
        } else {
            return "\(minutes) min"
        }
    }
}



enum Theme: Int {
    case light
    case dark
    case system
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil  // nil = seguir o sistema
        }
    }
}

enum ContentStrategy: String, CaseIterable {
    case relevant = "relevant"
    case new = "new"
    
    var displayName: String {
        switch self {
        case .relevant:
            return "Relevantes"
        case .new:
            return "Recentes"
        }
    }
    
    var icon: String {
        switch self {
        case .relevant:
            return "star.fill"
        case .new:
            return "clock.fill"
        }
    }
}
