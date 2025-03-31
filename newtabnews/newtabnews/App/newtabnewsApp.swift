//
//  newtabnewsApp.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI

@main
struct newtabnewsApp: App {
    
    init() {
        NotificationManager.shared.requestPermission()
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(searchText: "")
                    .navigationBarHidden(true)
            }
        }
    }
}
