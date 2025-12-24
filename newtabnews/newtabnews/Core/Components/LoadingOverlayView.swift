//
//  LoadingOverlay.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct LoadingOverlayView: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ProgressView(message)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
        }
    }
}
