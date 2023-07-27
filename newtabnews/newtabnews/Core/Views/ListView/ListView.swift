//
//  ListView.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct ListView: View {
    var viewModel: MainViewModel
    var posts: [ContentRequest]
    
    var body: some View {
        ScrollView {
            ForEach(posts) { post in
                NavigationLink {
                    ListDetailView(post: post)
                } label: {
                    CardList(title: post.title ?? "titulo", user: post.ownerUsername ?? "username", date: getFormattedDate(value: post.createdAt ?? "asdada"), bodyContent: post.entirePost ?? "erro porra")
                }
            }
        }
        .task {
            await viewModel.fetchContent()
            await viewModel.fetchPost()
        }
    }
}


