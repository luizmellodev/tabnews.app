//
//  CardList.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct CardList: View {
    var post: PostRequest
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                Text(post.title ?? "Ops")
                    .multilineTextAlignment(.leading)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)
                    .padding(.top, 20)
                HStack {
                    Text(post.ownerUsername ?? "luizmellodev")
                        .font(.footnote)
                    
                    Spacer()
                    
                    Text(getFormattedDate(value: post.createdAt ?? "sábado-feira, 31 fevereiro"))
                        .font(.footnote)
                        .italic()
                }
                .foregroundColor(.gray)
                
                Divider()
                
                if let body = post.body {
                    MDText(markdown: String(body.prefix(300)))
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                        .padding(.bottom, 20)
                }
                
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
            if post.tabcoins ?? 5 >= 15 {
                VStack {
                    HStack {
                        Spacer()
                        Text("Em alta")
                            .font(.footnote)
                            .foregroundStyle(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .fill(Color.green)
                                    .brightness(-0.2)
                            }
                    }
                    .padding(.top, -10)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color("CardColor").shadow(.drop(color: .green, radius: post.tabcoins ?? 5 >= 10 ? 1 : 0)))
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}
