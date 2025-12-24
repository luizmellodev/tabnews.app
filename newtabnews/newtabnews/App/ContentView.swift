//
//  ContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // MARK: - Properties
    let contentService: ContentServiceProtocol
        
    @AppStorage("current_theme") var currentTheme: Theme = .system
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [Folder]
    @Query private var highlights: [Highlight]
    @Query private var notes: [Note]
    
    @State var viewModel: MainViewModel
    @State var newsletterVM: NewsletterViewModel
    
    @State var searchText: String
    @State var showSnack: Bool = false
    @State var isViewInApp: Bool = true
    @State var alreadyLoaded: Bool = false
    @State var selectedTab: AppTab = .home
    @State var postToOpen: PostRequest? = nil
    @State var isLoadingPost: Bool = false
    
    init(
        searchText: String = "",
        contentService: ContentServiceProtocol = ContentService(),
        viewModel: MainViewModel? = nil,
        newsletterVM: NewsletterViewModel? = nil
    ) {
        self.searchText = searchText
        self.contentService = contentService
        self._viewModel = State(initialValue: viewModel ?? MainViewModel(service: contentService))
        self._newsletterVM = State(initialValue: newsletterVM ?? NewsletterViewModel(service: contentService))
    }
    
    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView(showOnboarding: $hasSeenOnboarding)
            } else {
                mainContent
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
    
    // MARK: - Views
    
    /// Conteúdo principal do app (TabView + Navegação)
    private var mainContent: some View {
        NavigationStack {
            MainTabView(
                selectedTab: $selectedTab,
                isViewInApp: $isViewInApp,
                currentTheme: $currentTheme,
                viewModel: viewModel,
                newsletterVM: newsletterVM
            )
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
                    LoadingOverlayView(message: "Carregando post...")
                }
            }
        }
        .environment(viewModel)
        .onAppear {
            loadInitialContent()
        }
    }
    
    // MARK: - Lifecycle
    
    /// Carrega conteúdo inicial ao abrir o app
    private func loadInitialContent() {
        // Carregar curtidos salvos
        viewModel.getLikedContent()
        
        // Sempre carregar conteúdo ao abrir o app
        if !alreadyLoaded {
            Task {
                await viewModel.fetchContent()
                await viewModel.fetchPost()
                alreadyLoaded = true
            }
        }
        
        viewModel.saveInAppSettings(viewInApp: isViewInApp)
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
            handleOpenNewsletterTab()
        }
        
        // Observar quando clicar em notificação push (abrir post específico)
        NotificationCenter.default.addObserver(
            forName: .openPostFromNotification,
            object: nil,
            queue: .main
        ) { [self] notification in
            handleOpenPost(from: notification)
        }
    }
    
    // MARK: - Notification Handlers
    
    /// Navega para a aba Newsletter
    private func handleOpenNewsletterTab() {
        print("📰 Navegando para aba Newsletter via notificação")
        selectedTab = .newsletter
    }
    
    /// Processa deep link de notificação e abre post específico
    private func handleOpenPost(from notification: Notification) {
        guard let postData = notification.object as? PostDeepLinkData else {
            print("❌ Dados do post inválidos")
            return
        }
        
        print("🔗 Deep link recebido: \(postData.owner)/\(postData.slug) (tipo: \(postData.type.rawValue))")
        
        // Navegar para aba apropriada baseado no tipo
        selectedTab = postData.type.isNewsletter ? .newsletter : .home
        
        // Buscar e abrir o post
        Task {
            await openPost(owner: postData.owner, slug: postData.slug)
        }
    }
    
    // MARK: - Deep Link
    
    /// Busca e abre um post específico via deep link
    @MainActor
    private func openPost(owner: String, slug: String) async {
        isLoadingPost = true
        
        do {
            let post = try await contentService.getPost(user: owner, slug: slug)
            
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
