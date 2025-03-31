//
//  PostRow.swift
//  newtabnews
//
//  Created by Luiz Mello on 31/03/25.
//

import SwiftUI

struct PostRow: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    
    let post: PostRequest

    
    var body: some View {
        NavigationLink {
            if isViewInApp {
                ListDetailView(
                    isViewInApp: $isViewInApp,
                    currentTheme: $currentTheme,
                    post: post
                )
                .environmentObject(viewModel)
            } else {
                WebContentView(content: post)
            }
        } label: {
            CardList(post: post)
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
