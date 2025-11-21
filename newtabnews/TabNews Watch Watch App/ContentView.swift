//
//  ContentView.swift
//  TabNews Watch Watch App
//
//  Created by Luiz Mello on 20/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Tab 1: Feed de Notícias
            WatchListView()
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }
            
            // Tab 2: Biblioteca
            LibraryWatchView()
                .tabItem {
                    Label("Biblioteca", systemImage: "book.pages")
                }
        }
    }
}

#Preview {
    ContentView()
}
