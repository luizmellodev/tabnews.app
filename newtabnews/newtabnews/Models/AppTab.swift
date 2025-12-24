//
//  AppTab.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import Foundation

enum AppTab: Int, CaseIterable {
    case home = 0
    case library = 1
    case newsletter = 2
    case settings = 3
    
    var title: String {
        switch self {
        case .home: return "Início"
        case .library: return "Biblioteca"
        case .newsletter: return "Newsletter"
        case .settings: return "Ajustes"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .library: return "book.pages"
        case .newsletter: return "newspaper.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
