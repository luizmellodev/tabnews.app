//
//  MainView.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct MainView: View {
    
    @Environment(MainViewModel.self) private var viewModel
    @AppStorage("current_theme") var currentTheme: Theme = .light
    @GestureState var press = false
    
    @State private var keyboardHeight: CGFloat = 0
    @State var searchText: String = ""
    @State var showSnack: Bool = false
    @State var isSearching = false
    @Binding var isViewInApp: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var isLoadingStrategy = false
    
    var body: some View {
        @Bindable var bindableViewModel = viewModel
        
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.state == .requestSucceeded || isLoadingStrategy {
                    Picker("Filtro", selection: $bindableViewModel.currentStrategy) {
                        ForEach(ContentStrategy.allCases, id: \.self) { strategy in
                            Label(strategy.displayName, systemImage: strategy.icon)
                                .tag(strategy)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .disabled(isLoadingStrategy)
                    .onChange(of: bindableViewModel.currentStrategy) { _, newStrategy in
                        Task {
                            isLoadingStrategy = true
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.state = .loading
                            }
                            await viewModel.fetchContent(with: newStrategy)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isLoadingStrategy = false
                            }
                        }
                    }
                }
                
                Group {
                    switch viewModel.state {
                    case .loading:
                        SkeletonListView()
                            .transition(.opacity)
                        
                    case .requestSucceeded:
                        ScrollView {
                            ListView(
                                searchText: $searchText,
                                isViewInApp: $isViewInApp,
                                currentTheme: $currentTheme,
                                posts: viewModel.content
                            )
                            .environment(viewModel)
                            .padding(.top, 5)
                        }
                        .transition(.opacity)
                        .id(viewModel.currentStrategy)
                        
                    case .requestFailed:
                        FailureView(currentTheme: $currentTheme)
                            .transition(.opacity)
                    default:
                        SkeletonListView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.state)
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStrategy)
            }
            .navigationTitle("Tab News")
            .navigationBarTitleDisplayMode(.large)
            .background {
                ZStack {
                    Color("Background")
                        .ignoresSafeArea()
                    Image("ruido")
                        .resizable()
                        .scaledToFill()
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Pesquisar")
        }
    }
}
