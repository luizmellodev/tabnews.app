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
    @State var selectedTab: Int = 0 // 0=Início, 1=Biblioteca, 2=Newsletter, 3=Ajustes
    
    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView(showOnboarding: $hasSeenOnboarding)
            } else {
                TabView(selection: $selectedTab) {
                    MainView(isViewInApp: $isViewInApp)
                        .tabItem {
                            Label("Início", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    FoldersView()
                        .tabItem {
                            Label("Biblioteca", systemImage: "book.pages")
                        }
                        .environment(viewModel)
                        .tag(1)
                    
                    NewsletterView(isViewInApp: $isViewInApp)
                        .tabItem {
                            Label("Newsletter", systemImage: "newspaper.fill")
                        }
                        .environment(newsletterVM)
                        .tag(2)
                    
                    SettingsView(isViewInApp: $isViewInApp, currentTheme: $currentTheme)
                        .tabItem {
                            Label("Ajustes", systemImage: "gearshape.fill")
                        }
                        .environment(viewModel)
                        .onChange(of: isViewInApp) { _, newvalue in
                            viewModel.defaults.set(newvalue, forKey: "viewInApp")
                        }
                        .tag(3)
                }
                .environment(viewModel)
                .onAppear {
                    // Carregar curtidos salvos
                    viewModel.getLikedContent()
                    
                    // Sempre carregar conteúdo ao abrir o app
                    if !alreadyLoaded {
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
        .onOpenURL { url in
            handleDeepLink(url)
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
    
    // MARK: - Deep Link Handler
    private func handleDeepLink(_ url: URL) {
        // Formato: tabnews://newsletter
        if url.host == "newsletter" {
            selectedTab = 2 // Navegar para aba Newsletter
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
