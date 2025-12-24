//
//  PostFileRow.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI

struct PostFileRow: View {
    let post: PostRequest
    var hasHighlights: Bool = false
    var hasNote: Bool = false
    var highlightPreview: String? = nil
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Spacer()
                    .frame(width: 12)
                
                Image(systemName: "doc.text")
                    .foregroundStyle(.secondary)
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(post.title ?? "Sem título")
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    if let preview = highlightPreview, hasHighlights {
                        Text("\(preview)")
                            .font(.caption)
                            .italic()
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 6) {
                        if hasHighlights {
                            HStack(spacing: 2) {
                                Image(systemName: "highlighter")
                                    .font(.caption2)
                                Text("Destacado")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.yellow)
                        }
                        if hasNote {
                            HStack(spacing: 2) {
                                Image(systemName: "note.text")
                                    .font(.caption2)
                                Text("Anotação")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.orange)
                        }
                        
                        if hasHighlights || hasNote {
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(post.ownerUsername ?? "")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.leading, 28)
    }
}

