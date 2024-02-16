//
//  ContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State var searchText: String
    @State var showSnack: Bool = false
    @State var isSearching = false
    @State var isViewInApp: Bool = true
    @AppStorage("current_theme") var currentTheme: Theme = .light
    
    var body: some View {
        TabView {
            MainView(viewModel: viewModel, searchText: searchText, showSnack: showSnack, isSearching: isSearching, isViewInApp: $isViewInApp)
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
                }
            
            LikedList(viewModel: viewModel, isViewInApp: $isViewInApp, showSnack: $showSnack)
                .tabItem {
                    Label("Curtidas", systemImage: "heart.fill")
                }
            
            NewsletterView(isViewInApp: $isViewInApp, viewModel: viewModel, newsletters: viewModel.newsletter)
                .tabItem {
                    Label("Newsletter", systemImage: "newspaper.fill")
                }
            
            SettingsView(viewModel: viewModel, isViewInApp: $isViewInApp, currentTheme: $currentTheme)
                .tabItem {
                    Label("Configurações", systemImage: "gearshape.fill")
                }
                .onChange(of: isViewInApp) { newvalue in
                    viewModel.defaults.set(newvalue, forKey: "viewInApp")
                }
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "First") == false {
                Task {
                    await viewModel.fetchContent()
                    await viewModel.fetchPost()
                    await viewModel.fetchNewsletter()
                }
            }
            viewModel.saveInAppSettings(viewInApp: isViewInApp)
        }
        .preferredColorScheme(currentTheme.colorScheme)
    }
}
