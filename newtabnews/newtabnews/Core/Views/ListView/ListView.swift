//
//  ListView.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct ListView: View {
    
    @Binding var searchText: String
    @Binding var isViewInApp: Bool
    
    var viewModel: MainViewModel
    var posts: [ContentRequest]
    
    var body: some View {
        ScrollView {
            ForEach(searchText.isEmpty ? posts : posts.filter({ content in
                guard let title = content.title else { return false }
                return title.localizedCaseInsensitiveContains(searchText)
            })) { post in
                NavigationLink { isViewInApp ?
                    AnyView(ListDetailView(post: post)) : AnyView(WebContentView(content: post))
                } label: {
                    CardList(title: post.title ?? "titulo", user: post.ownerUsername ?? "username", date: getFormattedDate(value: post.createdAt ?? "asdada"), bodyContent: post.entirePost ?? "erro porra")
                }
                .contextMenu {
                    Button {
                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                        impactHeavy.impactOccurred()
                        viewModel.likeContentList(content: post)
                    } label: {
                        Text("Curtir")
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}


