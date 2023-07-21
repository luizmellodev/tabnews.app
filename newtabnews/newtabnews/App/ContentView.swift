//
//  ContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    var body: some View {
        NavigationView {
            List(viewModel.content) { conteudo in
                NavigationLink {
                    TopicContent(content: viewModel.post ?? "deu ruim")
                } label: {
                    Text(conteudo.title ?? "titulo")
                        .foregroundColor(.blue)
                }
                .onAppear {
                    Task {
                        guard let user = conteudo.ownerUsername,
                              let slug = conteudo.slug else { return }
                        await viewModel .fetchPost(user: user, slug: slug)
                    }
                }

            }
            .navigationTitle("Notícias")
        }
        .task {
            await viewModel.fetchContent()
        }
    }
}

struct TopicContent: View {
    var content: String
    
    var body: some View {
        VStack {
            Text(content)
                .padding(20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ContentViewModel()
        ContentView(viewModel: viewModel)
    }
}