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
    @State var searchText: String
    @State var showSnack: Bool = false
    @State var isSearching = false
    @State var isViewInApp: Bool = true
    
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
                    Text("Tab News")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                    
                    SearchBar(searchText: $searchText, isSearching: $isSearching, searchPlaceHolder: "Pesquisar", searchCancel: "Cancelar")
                        .padding(.bottom, 10)
                    
                    ListView(viewModel: viewModel, posts: viewModel.content)
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .statusBarHidden()
    }
}
