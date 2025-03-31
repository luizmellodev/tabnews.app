//
//  ContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("current_theme") var currentTheme: Theme = .light
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    @StateObject var viewModel: MainViewModel = MainViewModel()
    @StateObject var newsletterVM: NewsletterViewModel = NewsletterViewModel()
    
    @State var searchText: String
    @State var showSnack: Bool = false
    @State var isSearching = false
    @State var isViewInApp: Bool = true
    @State var alreadyLoaded: Bool = false
    
    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView(showOnboarding: $hasSeenOnboarding)
            } else {
                TabView {
                    MainView(searchText: searchText, showSnack: showSnack, isSearching: isSearching, isViewInApp: $isViewInApp)
                        .tabItem {
                            Label("Menu", systemImage: "list.dash")
                        }
                    
                    LikedList(isViewInApp: $isViewInApp, currentTheme: $currentTheme, showSnack: $showSnack)
                        .tabItem {
                            Label("Curtidas", systemImage: "heart.fill")
                        }
                    
                    NewsletterView(isViewInApp: $isViewInApp)
                        .tabItem {
                            Label("Newsletter", systemImage: "newspaper.fill")
                        }
                        .environmentObject(newsletterVM)
                    
                    SettingsView(isViewInApp: $isViewInApp, currentTheme: $currentTheme)
                        .tabItem {
                            Label("Configurações", systemImage: "gearshape.fill")
                        }
                        .onChange(of: isViewInApp) { newvalue in
                            viewModel.defaults.set(newvalue, forKey: "viewInApp")
                        }
                }
                .environmentObject(viewModel)
                .onAppear {
                    if UserDefaults.standard.bool(forKey: "First") == false && !alreadyLoaded {
                        Task {
                            await viewModel.fetchContent()
                            await viewModel.fetchPost()
                            self.alreadyLoaded = true
                        }
                    }
                    viewModel.saveInAppSettings(viewInApp: isViewInApp)
                }
            }
        }
        .preferredColorScheme(currentTheme.colorScheme)
    }
}
