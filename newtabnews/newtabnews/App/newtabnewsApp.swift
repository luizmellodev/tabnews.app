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
        AppModuleDependencies().setupDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                let viewModel = MainViewModel()
                ContentView(searchText: "")
                    .environmentObject(viewModel)
                    .navigationBarHidden(true)
                
            }
        }
    }
}
