//
//  PostMetadataView.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct PostMetadataView: View {
    let post: PostRequest
    
    var body: some View {
        HStack {
            Text(post.ownerUsername ?? "luizmellodev")
                .font(.footnote)
            Spacer()
            Text(getFormattedDate(value: post.createdAt ?? "sábado-feira, 31 fevereiro"))
                .font(.footnote)
                .italic()
        }
        .foregroundColor(.gray)
    }
}

