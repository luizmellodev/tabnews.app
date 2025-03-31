//
//  LikedList.swift
//  tabnewsios
//
//  Created by Luiz Eduardo Mello dos Reis on 31/12/22.
//

import SwiftUI

struct LikedList: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    @Binding var showSnack: Bool
    
    var body: some View {
        NavigationView {
            LikedListContent(
                viewModel: viewModel,
                isViewInApp: $isViewInApp,
                currentTheme: $currentTheme,
                showSnack: $showSnack
            )
        }
        .onAppear {
            viewModel.getLikedContent()
        }
    }
}

private struct LikedListContent: View {
    @ObservedObject var viewModel: MainViewModel
    
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    @Binding var showSnack: Bool
    
    var body: some View {
        Group {
            if viewModel.likedList.isEmpty {
                EmptyLikedListView()
            } else {
                LikedListItems(
                    viewModel: viewModel,
                    isViewInApp: $isViewInApp,
                    currentTheme: $currentTheme
                )
            }
        }
    }
}

private struct LikedListItems: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.likedList) { post in
                    NavigationLink { isViewInApp ?
                        AnyView(ListDetailView(
                            isViewInApp: $isViewInApp,
                            currentTheme: $currentTheme,
                            post: post
                        )) : AnyView(WebContentView(content: post))
                    } label: {
                        HStack {
                            Text(post.title ?? "Erro pra pegar o título :/")
                        }
                    }
                }
                .onDelete(perform: removeRows)
            } header: {
                listHeader
            }
        }
        .toolbar {
            EditButton()
        }
    }
    
    private var listHeader: some View {
        Text("Seus favoritos")
            .font(.title)
            .fontWeight(.semibold)
            .textCase(nil)
            .foregroundColor(.primary)
            .padding(.bottom, 10)
    }
    
    private func removeRows(at offsets: IndexSet) {
        viewModel.likedList.remove(atOffsets: offsets)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(viewModel.likedList) {
            viewModel.defaults.set(encoded, forKey: "LikedContent")
        }
    }
}
