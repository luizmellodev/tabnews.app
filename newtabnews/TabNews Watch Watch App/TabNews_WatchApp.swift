//
//  TabNews_WatchApp.swift
//  TabNews Watch Watch App
//
//  Created by Luiz Mello on 20/11/25.
//

import SwiftUI

@main
struct TabNews_Watch_Watch_AppApp: App {
    
    init() {
        // Ativar WatchSync para receber dados do iPhone
        _ = WatchSyncManager.shared
        print("⌚ App iniciado, WatchSync ativo")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
