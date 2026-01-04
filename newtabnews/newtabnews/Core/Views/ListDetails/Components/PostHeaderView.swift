//
//  PostHeaderView.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct PostHeaderView: View {
    let post: PostRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.title ?? "Título indisponível :/")
                .padding(.top, 30)
                .font(.title2)
                .fontWeight(.medium)
                .lineSpacing(2)
        }
    }
}

