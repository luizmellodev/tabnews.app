//
//  newtabnewsApp.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI
import SwiftData

@main
struct newtabnewsApp: App {
    
    init() {
        NotificationManager.shared.requestPermission()
        AppUsageTracker.shared.startTracking() // Iniciar tracking de tempo
        
//        let tabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.configureWithDefaultBackground()
//        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(searchText: "")
        }
        .modelContainer(for: [Folder.self, Highlight.self, Note.self])
    }
}
