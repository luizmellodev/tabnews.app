//
//  MainView.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct MainView: View {
    
    @Environment(MainViewModel.self) var viewModel
    @AppStorage("current_theme") var currentTheme: Theme = .light
    @GestureState var press = false
    
    @State private var keyboardHeight: CGFloat = 0
    @State var searchText: String = ""
    @State var showSnack: Bool = false
    @State var isSearching = false
    @Binding var isViewInApp: Bool
    @State private var scrollOffset: CGFloat = 0
    
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
                        .bold()
                        .opacity(scrollOffset < 50 ? 1 : 0)
                        .animation(.easeInOut, value: scrollOffset)
                        .padding(.top, 100)
                        .padding(.bottom, 10)
                    
                    SearchBar(
                        searchText: $searchText,
                        isSearching: $isSearching,
                        searchPlaceHolder: "Pesquisar",
                        searchCancel: "Cancelar"
                    )
                    .padding(.top, isSearching ? 50 : 0)
                    .zIndex(1)
                    Spacer()
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                VStack(spacing: 0) {
                    switch viewModel.state {
                        
                    case .loading:
                        ProgressView()
                        
                    case .requestSucceeded:
                        ScrollView {
                            VStack(spacing: 0) {
                                ListView(
                                    searchText: $searchText,
                                    isViewInApp: $isViewInApp,
                                    currentTheme: $currentTheme,
                                    posts: viewModel.content
                                )
                                .environment(viewModel)
                            }
                        }
                        .scrollDismissesKeyboard(.immediately)
                        .padding(.top, isSearching ? 270 : 210)
                    case .requestFailed:
                        FailureView(currentTheme: $currentTheme)
                    default:
                        ProgressView()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
