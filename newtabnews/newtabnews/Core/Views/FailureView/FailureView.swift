//
//  FailureView.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import SwiftUI

struct FailureView: View {
    @Binding var currentTheme: Theme
    @State private var isDark: Bool = false
    
    var body: some View {
        ZStack (alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Image(isDark ? "errorDark" : "errorLight")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .blendMode(isDark ? .normal : .darken)
                .padding(.bottom, isDark ? 300 : 0)
                .padding(.top, isDark ? 20 : 0)
                .padding(.horizontal, isDark ? 40 : 0)

            
            VStack (alignment: .center) {
                Text("Vixe maria..")
                    .font(.title)
                    .bold()
                
                Text("Parece que algo deu errado, foi mal :/")
                    .multilineTextAlignment(.center)
                    .opacity(0.7)
                
                if currentTheme == .light {
                    Text("Aproveitando a oportunidade.. por quê você não tá usando Dark Mode, hein?!")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .opacity(0.4)
                        .padding(.top, 20)
                        .padding(.horizontal, 40)
                }
            }
            .padding(.bottom, 160)
        }
        .onAppear {
            isDark = (currentTheme == .dark)
        }
    }
}

struct FailureView_Previews: PreviewProvider {
    static var previews: some View {
        FailureView(currentTheme: .constant(.dark))
    }
}
