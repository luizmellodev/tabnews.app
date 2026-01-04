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
        VStack(alignment: .leading, spacing: family == .systemSmall ? 6 : 8) {
            // Header compacto para small
            if family == .systemSmall {
                HStack(spacing: 4) {
                    Image(systemName: "newspaper.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("Recentes")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
            } else {
                HStack {
                    Image(systemName: "newspaper.fill")
                        .foregroundStyle(.blue)
                    Text("Posts Recentes")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            ForEach(Array(posts.prefix(family == .systemSmall ? 1 : 3)), id: \.id) { post in
                Link(destination: post.url ?? URL(string: "tabnews://home")!) {
                    PostRow(post: post, family: family)
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
        VStack(alignment: .leading, spacing: family == .systemSmall ? 6 : 8) {
            // Header compacto para small
            if family == .systemSmall {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("Relevantes")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)
            } else {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("Posts Relevantes")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            ForEach(Array(posts.prefix(family == .systemSmall ? 1 : 3)), id: \.id) { post in
                Link(destination: post.url ?? URL(string: "tabnews://home")!) {
                    PostRow(post: post, showTabcoins: true, family: family)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct DigestView: View {
    let digest: WidgetPost
    let family: WidgetFamily
    
    // Extrair data da semana do título ou usar data atual
    private var weekInfo: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM"
        
        let calendar = Calendar.current
        let today = Date()
        
        // Pegar início e fim da semana
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return "Esta semana"
        }
        
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    var body: some View {
        ZStack {
            Link(destination: digest.url ?? URL(string: "tabnews://digest")!) {
                VStack(alignment: .leading, spacing: family == .systemSmall ? 10 : 14) {
                    // Header com semana
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(family == .systemSmall ? .caption : .body)
                                .foregroundStyle(.orange)
                            Text("Resumo Semanal")
                                .font(family == .systemSmall ? .caption : .subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        
                        // Mostrar semana apenas em medium/large
                        if family != .systemSmall {
                            Text(weekInfo)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Título do digest (mais espaço)
                    Text(digest.title)
                        .font(family == .systemSmall ? .caption : .body)
                        .fontWeight(family == .systemSmall ? .semibold : .medium)
                        .foregroundStyle(.primary)
                        .lineLimit(family == .systemSmall ? 3 : 5)
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
                .padding(family == .systemSmall ? 14 : 16)
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
    var family: WidgetFamily = .systemMedium
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: family == .systemSmall ? 2 : 4) {
                // Título
                Text(post.title)
                    .font(family == .systemSmall ? .system(size: 11, weight: .semibold) : .caption)
                    .fontWeight(.semibold)
                    .lineLimit(family == .systemSmall ? 3 : 2)
                
                // Metadados compactos
                HStack(spacing: 4) {
                    Text("@\(post.ownerUsername)")
                        .font(family == .systemSmall ? .system(size: 9) : .caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    if showTabcoins, let tabcoins = post.tabcoins {
                        Text("•")
                            .font(family == .systemSmall ? .system(size: 9) : .caption2)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                            Text("\(tabcoins)")
                        }
                        .font(family == .systemSmall ? .system(size: 9) : .caption2)
                        .foregroundStyle(.orange)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, family == .systemSmall ? 12 : 16)
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
