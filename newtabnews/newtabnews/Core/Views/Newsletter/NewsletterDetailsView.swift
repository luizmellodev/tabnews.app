//
//  PostDetailView.swift
//  newtabnews
//
//  Created by Luiz Mello on 11/03/25.
//


import SwiftUI

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(post.title)
                    .font(.title)
                    .bold()
                
                if let content = post.content {
                    Text(content)
                        .font(.body)
                        .lineSpacing(5)
                } else {
                    ProgressView() // Carregando conteúdo
                }
            }
            .padding()
        }
        .navigationTitle("Post")
    }
}
