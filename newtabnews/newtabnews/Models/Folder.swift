//
//  Folder 2.swift
//  newtabnews
//
//  Created by Luiz Mello on 19/11/25.
//

import Foundation
import SwiftData

@Model
final class Folder {
    var id: UUID
    var name: String
    var icon: String // SF Symbol name ou emoji
    var colorHex: String // Cor em hex
    var createdAt: Date
    var postIds: [String] // IDs dos posts salvos nesta pasta
    
    init(name: String, icon: String = "folder.fill", colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = Date()
        self.postIds = []
    }
    
    func addPost(_ postId: String) {
        if !postIds.contains(postId) {
            postIds.append(postId)
        }
    }
    
    func removePost(_ postId: String) {
        postIds.removeAll { $0 == postId }
    }
    
    var postCount: Int {
        postIds.count
    }
}

