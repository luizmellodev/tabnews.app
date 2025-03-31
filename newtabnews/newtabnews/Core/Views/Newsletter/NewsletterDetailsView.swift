//
//  NewsletterDetailsView.swift
//  newtabnews
//
//  Created by Luiz Mello on 11/03/25.
//


import SwiftUI

struct NewsletterDetailsView: View {
    let nw: PostRequest?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(nw?.title ?? "Sem título (agora leia aqui)")
                    .font(.title)
                    .bold()
                
                if let content = nw {
                    Text(content.body ?? "Ops, problema pra pegar esse conteúdo")
                        .font(.body)
                        .lineSpacing(5)
                } else {
                    ProgressView()
                }
            }
            .padding()
        }
        .navigationTitle("Post")
    }
}
