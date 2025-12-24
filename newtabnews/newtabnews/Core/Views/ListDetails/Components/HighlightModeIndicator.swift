//
//  HighlightModeIndicator.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct HighlightModeIndicator: View {
    var body: some View {
        HStack {
            Image(systemName: "hand.tap")
                .foregroundStyle(.yellow)
            Text("Selecione o texto para destacar")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.yellow.opacity(0.05))
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
}

