//
//  DailyDigest.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/02/26.
//

import Foundation

struct DailyDigestItem: Identifiable, Codable, Equatable {
    let id: String
    let post: PostRequest
    let score: Int
    
    static func == (lhs: DailyDigestItem, rhs: DailyDigestItem) -> Bool {
        lhs.id == rhs.id
    }
    
    init(post: PostRequest) {
        self.id = post.id ?? UUID().uuidString
        self.post = post
        
        let tabcoins = post.tabcoins ?? 0
        let comments = post.childrenDeepCount ?? 0
        self.score = tabcoins + (comments * 2)
    }
}

struct DailyDigest: Codable, Equatable {
    let date: Date
    let items: [DailyDigestItem]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter.string(from: date).capitalized
    }
}
