//
//  FailureView.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import SwiftUI

struct FailureView: View {
    var body: some View {
        ZStack (alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            Image(uiImage: #imageLiteral(resourceName: "3_Something Went Wrong"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .blendMode(.darken)
            
            VStack (alignment: .center) {
                Text("Vixe maria..")
                    .font(.title)
                    .bold()
                
                Text("Parece que algo deu errado, foi mal :/")
                    .multilineTextAlignment(.center)
                    .opacity(0.7)
            }
            .padding(.bottom, 160)
        }
    }
}

struct FailureView_Previews: PreviewProvider {
    static var previews: some View {
        FailureView()
    }
}
