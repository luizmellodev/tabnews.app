//
//  ListDetailsView.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import Foundation
import SwiftUI

struct ListDetailView: View {
    @State var post: ContentRequest
    @State private var showingTabNews = false
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(post.title ?? "merda")
                            .padding(.top, 30)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 10)
                        Spacer()
                        Button {
                            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                            impactHeavy.impactOccurred()
                            if viewModel.likedList.contains(where: { $0.title == post.title }) {
                                viewModel.removeContentList(content: post)
                            }
                            else {
                                viewModel.likeContentList(content: post)
                            }
                        } label: {
                            if viewModel.likedList.contains(where: { $0.title == post.title }) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "heart")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    HStack {
                        Text(post.ownerUsername ?? "fodase")
                            .font(.footnote)
                        Spacer()
                        Text(getFormattedDate(value: post.createdAt ?? "caralho"))
                            .font(.footnote)
                            .italic()
                    }
                    .foregroundColor(.gray)
                    Divider()
                    MDText(markdown: post.entirePost ?? "erro")
                        .padding(.bottom, 80)
                }
                .padding(.horizontal, 30)
            }
            .sheet(isPresented: $showingTabNews) {
                WebContentView(content: post)
                    .presentationDetents([.large, .large])
                    .presentationDragIndicator(.hidden)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingTabNews = true
                    }, label: {
                        Text("Ler no Tab News")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(Color.blue)
                            }
                            .padding(.trailing, 30)
                            .padding(.bottom, 20)
                    })
                }
            }
        }
    }
}

struct ListDetailView_Previews: PreviewProvider {
    static var viewModel = MainViewModel()
    static var previews: some View {
        ListDetailView(post: ContentRequest(id: nil, ownerID: nil, parentID: nil, slug: nil, title: nil, status: nil, sourceURL: nil, createdAt: nil, updatedAt: nil, publishedAt: nil, deletedAt: nil, ownerUsername: nil, tabcoins: nil, childrenDeepCount: nil), viewModel: viewModel)
    }
}
