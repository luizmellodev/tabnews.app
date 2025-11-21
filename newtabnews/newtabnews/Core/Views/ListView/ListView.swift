//
//  ListView.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct ListView: View {
    
    @Environment(MainViewModel.self) var viewModel
    @Binding var searchText: String
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    var posts: [PostRequest]
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(filteredPosts.enumerated()), id: \.element.id) { index, post in
                PostRow(
                    isViewInApp: $isViewInApp,
                    currentTheme: $currentTheme,
                    post: post
                )
                .environment(viewModel)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
                .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.05), value: filteredPosts.count)
            }
        }
        .padding(.horizontal, 5)
    }
    
    private var filteredPosts: [PostRequest] {
        if searchText.isEmpty {
            return posts
        } else {
            return posts.filter { post in
                guard let title = post.title else { return false }
                return title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
