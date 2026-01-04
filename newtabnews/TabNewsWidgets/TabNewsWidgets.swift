//
//  TabNewsWidgets.swift
//  TabNewsWidgets
//
//  Created by Luiz Mello on 04/01/26.
//

import WidgetKit
import SwiftUI

// MARK: - Data Service

struct WidgetDataService {
    @AppStorage("RecentPosts", store: UserDefaults(suiteName: "group.tabnews.com.app.tabnews-ios")) private var recentPostsData: Data?
    @AppStorage("WeekDigest", store: UserDefaults(suiteName: "group.tabnews.com.app.tabnews-ios")) private var digestData: Data?
    
    func fetchRecentPosts() -> [WidgetPost] {
        guard let data = recentPostsData,
              let decoded = try? JSONDecoder().decode([WidgetPost].self, from: data) else {
            return []
        }
        return Array(decoded.prefix(10))
    }
    
    func fetchRelevantPosts() -> [WidgetPost] {
        let posts = fetchRecentPosts()
        return posts.sorted { ($0.tabcoins ?? 0) > ($1.tabcoins ?? 0) }
    }
    
    func fetchWeekDigest() -> WidgetPost? {
        guard let data = digestData,
              let decoded = try? JSONDecoder().decode(WidgetPost.self, from: data) else {
            return nil
        }
        return decoded
    }
}

// MARK: - Timeline Provider

struct TabNewsWidgetProvider: AppIntentTimelineProvider {
    let dataService = WidgetDataService()
    
    func placeholder(in context: Context) -> TabNewsWidgetEntry {
        TabNewsWidgetEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            posts: WidgetPost.mockPosts,
            digest: WidgetPost.mockDigest
        )
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> TabNewsWidgetEntry {
        let posts: [WidgetPost]
        let digest: WidgetPost?
        
        switch configuration.contentType {
        case .recent:
            posts = dataService.fetchRecentPosts()
            digest = nil
        case .relevant:
            posts = dataService.fetchRelevantPosts()
            digest = nil
        case .digest:
            posts = []
            digest = dataService.fetchWeekDigest()
        }
        
        return TabNewsWidgetEntry(
            date: Date(),
            configuration: configuration,
            posts: posts.isEmpty ? WidgetPost.mockPosts : posts,
            digest: digest ?? WidgetPost.mockDigest
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<TabNewsWidgetEntry> {
        let posts: [WidgetPost]
        let digest: WidgetPost?
        let updateInterval: TimeInterval
        
        switch configuration.contentType {
        case .recent:
            posts = dataService.fetchRecentPosts()
            digest = nil
            updateInterval = 30 * 60
            
        case .relevant:
            posts = dataService.fetchRelevantPosts()
            digest = nil
            updateInterval = 60 * 60
            
        case .digest:
            posts = []
            digest = dataService.fetchWeekDigest()
            updateInterval = 6 * 60 * 60
        }
        
        let entry = TabNewsWidgetEntry(
            date: Date(),
            configuration: configuration,
            posts: posts,
            digest: digest
        )
        
        let nextUpdate = Date().addingTimeInterval(updateInterval)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - Timeline Entry

struct TabNewsWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let posts: [WidgetPost]
    let digest: WidgetPost?
}

// MARK: - Widget View

struct TabNewsWidgetView: View {
    var entry: TabNewsWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch entry.configuration.contentType {
        case .recent:
            RecentPostsView(posts: entry.posts, family: family)
        case .relevant:
            RelevantPostsView(posts: entry.posts, family: family)
        case .digest:
            if let digest = entry.digest {
                DigestView(digest: digest, family: family)
            } else {
                EmptyDigestView(family: family)
            }
        }
    }
}

// MARK: - Views

struct RecentPostsView: View {
    let posts: [WidgetPost]
    let family: WidgetFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "newspaper.fill")
                    .foregroundStyle(.blue)
                Text("Posts Recentes")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(Array(posts.prefix(family == .systemSmall ? 1 : 3)), id: \.id) { post in
                Link(destination: post.url ?? URL(string: "tabnews://home")!) {
                    PostRow(post: post)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct RelevantPostsView: View {
    let posts: [WidgetPost]
    let family: WidgetFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Posts Relevantes")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(Array(posts.prefix(family == .systemSmall ? 1 : 3)), id: \.id) { post in
                Link(destination: post.url ?? URL(string: "tabnews://home")!) {
                    PostRow(post: post, showTabcoins: true)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct DigestView: View {
    let digest: WidgetPost
    let family: WidgetFamily
    
    var body: some View {
        ZStack {
            Link(destination: digest.url ?? URL(string: "tabnews://digest")!) {
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)
                            .font(.title3)
                        Text("Resumo Semanal")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    
                    // Título do digest
                    Text(digest.title)
                        .font(family == .systemSmall ? .caption : .subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(family == .systemSmall ? 3 : 4)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Footer com info
                    HStack {
                        Text("@\(digest.ownerUsername)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if let tabcoins = digest.tabcoins {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                Text("\(tabcoins)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.orange)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct EmptyDigestView: View {
    let family: WidgetFamily
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle")
                .font(.system(size: family == .systemSmall ? 32 : 48))
                .foregroundStyle(.orange.opacity(0.6))
            
            Text("Resumo Semanal")
                .font(family == .systemSmall ? .caption : .headline)
                .foregroundStyle(.primary)
            
            Text("Aguardando dados...")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PostRow: View {
    let post: WidgetPost
    var showTabcoins: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack {
                    Text("@\(post.ownerUsername)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if showTabcoins, let tabcoins = post.tabcoins {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                            Text("\(tabcoins)")
                        }
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Widget Configuration

struct TabNewsWidget: Widget {
    let kind: String = "TabNewsWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: TabNewsWidgetProvider()
        ) { entry in
            TabNewsWidgetView(entry: entry)
        }
        .configurationDisplayName("TabNews")
        .description("Acompanhe o TabNews direto da tela inicial")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
