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
    var tabcoins: Int
    
    var body: some View {
        ZStack {
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
            if tabcoins >= 10 {
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
                .fill(Color("CardColor").shadow(.drop(color: .green, radius: tabcoins >= 10 ? 1 : 0)))
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}

#Preview {
    CardList(title: "Testeee", user: "luizmellodev", date: "09/04/2000", bodyContent: "asdjnahjdnmsadbhnjsamdfhbdsnjmkfshbnfjmksjhdknmasldjnasldjasliejasldknsaljkdnskdjfnsdkjfndasldmas;odksa;dmasl;kdmsakldnaskjdnsaodsakl", tabcoins: 20)
}

