//
//  ContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
        
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
    
    private func loadInitialContent() {
        viewModel.getLikedContent()
        
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
        NotificationCenter.default.addObserver(
            forName: .postsLoaded,
            object: nil,
            queue: .main
        ) { _ in
            syncToWatch()
        }
        
        NotificationCenter.default.addObserver(
            forName: .likedListUpdated,
            object: nil,
            queue: .main
        ) { _ in
            syncToWatch()
        }
        
        NotificationCenter.default.addObserver(
            forName: .highlightsUpdated,
            object: nil,
            queue: .main
        ) { _ in
            syncToWatch()
        }
        
        NotificationCenter.default.addObserver(
            forName: .notesUpdated,
            object: nil,
            queue: .main
        ) { _ in
            syncToWatch()
        }
        
        NotificationCenter.default.addObserver(
            forName: .foldersUpdated,
            object: nil,
            queue: .main
        ) { _ in
            syncToWatch()
        }
        
        NotificationCenter.default.addObserver(
            forName: .openNewsletterTab,
            object: nil,
            queue: .main
        ) { [self] _ in
            handleOpenNewsletterTab()
        }
        
        NotificationCenter.default.addObserver(
            forName: .openPostFromNotification,
            object: nil,
            queue: .main
        ) { [self] notification in
            handleOpenPost(from: notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: .watchLikedPostsReceived,
            object: nil,
            queue: .main
        ) { [self] notification in
            handleWatchLikedPosts(notification)
        }
    }
    
    // MARK: - Notification Handlers
    
    private func handleOpenNewsletterTab() {
        selectedTab = .newsletter
    }
    
    private func handleOpenPost(from notification: Notification) {
        guard let postData = notification.object as? PostDeepLinkData else {
            return
        }
        
        selectedTab = postData.type.isNewsletter ? .newsletter : .home
        
        Task {
            await openPost(owner: postData.owner, slug: postData.slug)
        }
    }
    
    // MARK: - Deep Link
    
    @MainActor
    private func openPost(owner: String, slug: String) async {
        isLoadingPost = true
        
        do {
            let post = try await contentService.getPost(user: owner, slug: slug)
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            postToOpen = post
            isLoadingPost = false
        } catch {
            isLoadingPost = false
        }
    }
    
    // MARK: - Watch Sync
    
    private func syncToWatch() {
        let recentPosts = Array(viewModel.content.prefix(5))
        let likedPosts = Array(viewModel.likedList.prefix(10))
        
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
    
    private func handleWatchLikedPosts(_ notification: Notification) {
        guard let watchLikedPosts = notification.object as? [PostRequest] else { return }
        
        for post in watchLikedPosts {
            if !viewModel.likedList.contains(where: { $0.id == post.id }) {
                viewModel.likeContentList(content: post)
            }
        }
    }
}
