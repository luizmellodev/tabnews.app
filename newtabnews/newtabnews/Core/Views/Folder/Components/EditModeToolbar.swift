//
//  EditModeToolbar.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct EditModeToolbar: View {
    let selectedCount: Int
    let onDelete: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button {
                onDelete()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.title3)
                    Text("Excluir (\(selectedCount))")
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
            
            Button {
                onClear()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash.slash")
                        .font(.title3)
                    Text("Limpar (\(selectedCount))")
                        .font(.caption)
                }
                .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

