//
//  CardList.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct CardList: View {
    var title: String
    var user: String
    var date: String
    var bodyContent: String
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 5)
                .padding(.top, 20)
            HStack {
                Text(user)
                    .font(.footnote)
                Spacer()
                Text(date)
                    .font(.footnote)
                    .italic()
            }
            .foregroundColor(.gray)
            Divider()
            MDText(markdown: String(bodyContent.prefix(300)))
                .fontWeight(.light)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .padding(.bottom, 20)
            NavigationLink {
                EmptyView()
            } label: {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(height: 40)
                        .foregroundColor(.black)
                        .overlay {
                            Text("Ler mais")
                                .foregroundColor(.white)
                        }
                }
                .padding(.bottom, 10)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color("CardColor"))
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}

