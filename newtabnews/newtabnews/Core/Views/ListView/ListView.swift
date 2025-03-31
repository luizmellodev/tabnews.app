//
//  ListView.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct ListView: View {
    
    @EnvironmentObject var viewModel: MainViewModel
    @Binding var searchText: String
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    var posts: [PostRequest]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(filteredPosts) { post in
                    PostRow(
                        isViewInApp: $isViewInApp,
                        currentTheme: $currentTheme,
                        post: post
                    )
                    .environmentObject(viewModel)
                }
            }
        }
        .padding(.bottom, 70)
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
