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
        ScrollView {
            VStack {
                Text("Teste")
                ForEach(viewModel.content, content: { conteudo in
                    Text(conteudo.title)
                        .foregroundColor(.blue)
                })
            }
        }
        .task {
            await viewModel.fetchContent()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ContentViewModel()
        ContentView(viewModel: viewModel)
    }
}
