//
//  SpecialFolderRow.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct SpecialFolderRow: View {
    let name: String
    let icon: String
    let color: String
    let count: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 12)
                    .animation(.spring(response: 0.3), value: isExpanded)
                
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                    .font(.title3)
                
                Text(name)
                    .foregroundColor(.primary)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

