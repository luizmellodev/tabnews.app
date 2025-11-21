//
//  ContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @AppStorage("current_theme") var currentTheme: Theme = .system
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [Folder]
    @Query private var highlights: [Highlight]
    @Query private var notes: [Note]
    
    @State var viewModel: MainViewModel = MainViewModel()
    @State var newsletterVM: NewsletterViewModel = NewsletterViewModel()
    
    @State var searchText: String
    @State var showSnack: Bool = false
    @State var isViewInApp: Bool = true
    @State var alreadyLoaded: Bool = false
    
    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView(showOnboarding: $hasSeenOnboarding)
            } else {
                TabView {
                    MainView(isViewInApp: $isViewInApp)
                        .tabItem {
                            Label("Início", systemImage: "house.fill")
                        }
                    
                    FoldersView()
                        .tabItem {
                            Label("Biblioteca", systemImage: "book.pages")
                        }
                        .environment(viewModel)
                    
                    NewsletterView(isViewInApp: $isViewInApp)
                        .tabItem {
                            Label("Newsletter", systemImage: "newspaper.fill")
                        }
                        .environment(newsletterVM)
                    
                    SettingsView(isViewInApp: $isViewInApp, currentTheme: $currentTheme)
                        .tabItem {
                            Label("Ajustes", systemImage: "gearshape.fill")
                        }
                        .environment(viewModel)
                        .onChange(of: isViewInApp) { _, newvalue in
                            viewModel.defaults.set(newvalue, forKey: "viewInApp")
                        }
                }
                .environment(viewModel)
                .onAppear {
                    // Carregar curtidos salvos
                    viewModel.getLikedContent()
                    
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
        .onAppear {
            setupObservers()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                syncToWatch()
            }
        }
    }
    
    // MARK: - Observers
    private func setupObservers() {
        // Sincronizar APÓS posts carregarem
        NotificationCenter.default.addObserver(
            forName: .postsLoaded,
            object: nil,
            queue: .main
        ) { _ in
            print("📱 Posts carregados, sincronizando com Watch...")
            syncToWatch()
        }
    }
    
    // MARK: - Watch Sync (SUPER SIMPLES!)
    private func syncToWatch() {
        let recentPosts = Array(viewModel.content.prefix(5))
        let likedPosts = Array(viewModel.likedList.prefix(10)) // Últimos 10 curtidos
        
        // DEBUG: Ver quais posts curtidos estão sendo enviados
        print("📱 [ContentView] likedList total: \(viewModel.likedList.count)")
        print("📱 [ContentView] Enviando \(likedPosts.count) posts curtidos:")
        for (i, post) in likedPosts.enumerated() {
            print("   \(i+1). \(post.title ?? "sem título")")
        }
        
        let stats = [
            "liked": viewModel.likedList.count,
            "highlights": highlights.count,
            "notes": notes.count,
            "folders": folders.count
        ]
        
        WatchSyncManager.shared.syncToWatch(
            posts: recentPosts,
            likedPosts: likedPosts,
            stats: stats
        )
    }
}
