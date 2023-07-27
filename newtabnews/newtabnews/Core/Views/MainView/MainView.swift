//
//  MainView.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI


//ForEach(Array(zip(contentList.indices, searchText.isEmpty ? contentList : contentList.filter { $0.title.contains(searchText) })), id: \.0) {index, content in

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    @GestureState var press = false
    @State var searchText: String = ""
    @State var showSnack: Bool = false
    @State var isSearching = false
    @State var isViewInApp: Bool = true
    @AppStorage("current_theme") var currentTheme: Theme = .light

    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                Image("ruido")
                    .resizable()
                    .scaledToFill()
                    .blendMode(.overlay)
                    .ignoresSafeArea()
                VStack {
                    // MARK: - View State
                    switch viewModel.state {
                    case .loading:
                        ProgressView()
                    case .requestSucceeded:
                        Text("Tab News")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 70)
                        SearchBar(searchText: $searchText, isSearching: $isSearching, searchPlaceHolder: "Pesquisar", searchCancel: "Cancelar")
                            .padding(.bottom, 10)
                        ListView(searchText: $searchText, isViewInApp: $isViewInApp, viewModel: viewModel, posts: viewModel.content)
                        Spacer()

                    case .requestFailed:
                        FailureView(currentTheme: $currentTheme)
                    default:
                        ProgressView()
                    }
                }
            }
            .task {
                await viewModel.fetchContent()
                await viewModel.fetchPost()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBarHidden()
    }
}
