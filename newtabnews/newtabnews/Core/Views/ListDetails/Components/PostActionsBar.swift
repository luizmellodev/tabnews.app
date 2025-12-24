//
//  PostActionsBar.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI
import SwiftData

struct PostActionsBar: View {
    @Environment(MainViewModel.self) var viewModel
    
    let post: PostRequest
    let postHighlights: [Highlight]
    @Binding var isHighlightMode: Bool
    @Binding var showingAddNote: Bool
    @Binding var showAudioControls: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HighlightButton(
                isHighlightMode: $isHighlightMode,
                highlightsCount: postHighlights.count
            )
            
            NoteButton(showingAddNote: $showingAddNote)
            
            LikeButton(post: post, viewModel: viewModel)
            
            Spacer()
            
            AudioButton(showAudioControls: $showAudioControls)
        }
        .padding(.bottom, 4)
    }
}

struct HighlightButton: View {
    @Binding var isHighlightMode: Bool
    let highlightsCount: Int
    
    var body: some View {
        Button {
            withAnimation {
                isHighlightMode.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isHighlightMode ? "checkmark.circle.fill" : "highlighter")
                if isHighlightMode {
                    Text("Concluir")
                        .font(.caption)
                } else if highlightsCount > 0 {
                    Text("\(highlightsCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                } else {
                    Text("Destacar")
                        .font(.caption)
                }
            }
            .foregroundColor(isHighlightMode ? .green : (highlightsCount == 0 ? .yellow : .orange))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background((isHighlightMode ? Color.green : (highlightsCount == 0 ? Color.yellow : Color.orange)).opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct NoteButton: View {
    @Binding var showingAddNote: Bool
    
    var body: some View {
        Button {
            showingAddNote = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "note.text.badge.plus")
                Text("Anotar")
                    .font(.caption)
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct LikeButton: View {
    let post: PostRequest
    let viewModel: MainViewModel
    
    private var isLiked: Bool {
        viewModel.likedList.contains(where: { $0.title == post.title })
    }
    
    var body: some View {
        Button {
            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()
            
            if isLiked {
                viewModel.removeContentList(content: post)
            } else {
                viewModel.likeContentList(content: post)
            }
        } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundColor(isLiked ? .red : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

struct AudioButton: View {
    @Binding var showAudioControls: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                showAudioControls.toggle()
            }
        } label: {
            Image(systemName: showAudioControls ? "speaker.wave.2.fill" : "speaker.wave.2")
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(showAudioControls ? 0.2 : 0.1))
                .cornerRadius(8)
        }
    }
}

