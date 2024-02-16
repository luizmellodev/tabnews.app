//
//  LikedList.swift
//  tabnewsios
//
//  Created by Luiz Eduardo Mello dos Reis on 31/12/22.
//

import SwiftUI

struct LikedList: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var isViewInApp: Bool
    @Binding var showSnack: Bool
    @State private var selectedItems: Set<Int> = []
    @StateObject private var gameController = GameController()

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
                if viewModel.likedList.isEmpty {
                    VStack {
                        Text("Ops! Você ainda não curtiu nenhum conteúdo")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        Image(systemName: "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60)
                            .foregroundColor(.gray)
                        
                        
                        NavigationLink {
                            Game(controller: self.gameController)
                                .onAppear {
                                    self.gameController.activate()
                                }            } label: {
                            Text("O jogo")
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    List {
                        HStack {
                            Text("Seus favoritos")
                                .font(.title)
                                .fontWeight(.semibold)
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        ForEach(Array(zip(viewModel.likedList.indices, viewModel.likedList)), id: \.0) {index, post in
                            NavigationLink { isViewInApp ?
                                AnyView(ListDetailView(post: post, viewModel: viewModel)) : AnyView(WebContentView(content: post))
                            } label: {
                                HStack {
                                    Text(post.title ?? "fodase")
                                }
                            }
                        }
                        .onDelete(perform: removeRows)
                    }
                    .toolbar {
                        ToolbarItem {
                            EditButton()
                        }
                    }
                    .padding(.top, 60)
                    .refreshable {
                        await viewModel.fetchContent()
                    }
                }
            }
        }
        .onAppear {
            viewModel.getLikedContent()
        }
    }
    func removeRows(at offsets: IndexSet) {
        viewModel.likedList.remove(atOffsets: offsets)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(viewModel.likedList) {
            viewModel.defaults.set(encoded, forKey: "LikedContent")
        }
    }
}

struct LikedListView_Previews: PreviewProvider {
    static var viewModel = MainViewModel()
    static var previews: some View {
        LikedList(viewModel: viewModel, isViewInApp: .constant(false), showSnack: .constant(false))
    }
}
