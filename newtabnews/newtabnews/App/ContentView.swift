//
//  ContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 01/07/23.
//

import SwiftUI
struct ContentView: View {
    @ObservedObject var viewModel: MainViewModel
    @State var searchText: String
    @State var showSnack: Bool = false
    @State var isSearching = false
    @State var isViewInApp: Bool = true
    @AppStorage("current_theme") var currentTheme: Theme = .light

    var body: some View {
        TabView {
            MainView(viewModel: viewModel, searchText: searchText, showSnack: showSnack, isSearching: isSearching, isViewInApp: isViewInApp)
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
                }
            
            LikedList(viewModel: viewModel, isViewInApp: $isViewInApp, showSnack: $showSnack)
                .tabItem {
                    Label("Curtidas", systemImage: "heart.fill")
                }
            
            SettingsView(isViewInApp: $isViewInApp, viewModel: viewModel, currentTheme: $currentTheme)
                .tabItem {
                    Label("Configurações", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            viewModel.saveInAppSettings(viewInApp: isViewInApp)
        }
        .preferredColorScheme(currentTheme.colorScheme)        
    }
}

//struct ContentView: View {
//    @ObservedObject var viewModel: ContentViewModel
//    var body: some View {
//        NavigationView {
//            List(viewModel.content) { conteudo in
//                NavigationLink {
//                    TopicContent(content: viewModel.post ?? "deu ruim")
//                } label: {
//                    Text(conteudo.title ?? "titulo")
//                        .foregroundColor(.blue)
//                }
//                .onAppear {
//                    Task {
//                        guard let user = conteudo.ownerUsername,
//                              let slug = conteudo.slug else { return }
//                        await viewModel .fetchPost(user: user, slug: slug)
//                    }
//                }
//
//            }
//            .navigationTitle("Notícias")
//        }
//        .task {
//            await viewModel.fetchContent()
//        }
//    }
//}
//
//struct TopicContent: View {
//    var content: String
//
//    var body: some View {
//        VStack {
//            Text(content)
//                .padding(20)
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = ContentViewModel()
//        ContentView(viewModel: viewModel)
//    }
//}
