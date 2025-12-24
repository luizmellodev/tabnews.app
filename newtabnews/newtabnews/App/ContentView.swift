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
    @State var postToOpen: PostRequest? = nil
    @State var isLoadingPost: Bool = false
    
    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView(showOnboarding: $hasSeenOnboarding)
            } else {
                NavigationStack {
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
                    .navigationDestination(item: $postToOpen) { post in
                        ListDetailView(
                            isViewInApp: $isViewInApp,
                            currentTheme: $currentTheme,
                            post: post
                        )
                        .environment(viewModel)
                    }
                    .overlay {
                        if isLoadingPost {
                            ZStack {
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea()
                                ProgressView("Carregando post...")
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                            }
                        }
                    }
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
        
        // Observar quando clicar em notificação push (apenas abrir aba)
        NotificationCenter.default.addObserver(
            forName: .openNewsletterTab,
            object: nil,
            queue: .main
        ) { [self] _ in
            print("📰 Navegando para aba Newsletter via notificação")
            selectedTab = 2
        }
        
        // Observar quando clicar em notificação push (abrir post específico)
        NotificationCenter.default.addObserver(
            forName: .openPostFromNotification,
            object: nil,
            queue: .main
        ) { [self] notification in
            guard let postData = notification.object as? PostDeepLinkData else {
                print("❌ Dados do post inválidos")
                return
            }
            
            print("🔗 Deep link recebido: \(postData.owner)/\(postData.slug) (tipo: \(postData.type))")
            
            // Se for newsletter, navegar para aba Newsletter
            if postData.type == "newsletter" || postData.type == "test_newsletter" {
                print("📰 Tipo newsletter - navegando para tab Newsletter")
                selectedTab = 2
            } else {
                // Se for post relevante, manter na Home (tab 0)
                print("🔥 Tipo post relevante - mantendo na Home")
                selectedTab = 0
            }
            
            // Buscar e abrir o post
            Task {
                await openPost(owner: postData.owner, slug: postData.slug)
            }
        }
    }
    
    // MARK: - Deep Link
    @MainActor
    private func openPost(owner: String, slug: String) async {
        isLoadingPost = true
        
        do {
            let service = ContentService()
            let post = try await service.getPost(user: owner, slug: slug)
            
            // Aguardar um pouco para garantir que a navegação da tab terminou
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 segundos
            
            postToOpen = post
            isLoadingPost = false
            
            print("✅ Post carregado e navegação iniciada")
        } catch {
            print("❌ Erro ao buscar post: \(error)")
            isLoadingPost = false
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
