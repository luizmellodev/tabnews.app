//
//  ListDetailsView.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import Foundation
import SwiftUI
import SwiftData

struct ListDetailView: View {
    
    @Environment(MainViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    @StateObject private var ttsManager = TextToSpeechManager.shared

    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    
    @State var post: PostRequest
    @State private var showingTabNews = false
    @State private var showingAddNote = false
    @State private var showingHighlightSheet = false
    @State private var isHighlightMode = false
    @State private var showAudioControls = false
    @Query private var highlights: [Highlight]
    
    private var postHighlights: [Highlight] {
        highlights.filter { $0.postId == post.id }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    postHeader
                    PostMetadataView(post: post)
                    Divider()
                    
                    if isHighlightMode {
                        HighlightModeIndicator()
                    }
                    
                    postContent
                }
                .padding(.horizontal, 20)
            }
            .sheet(isPresented: $showingTabNews) {
                WebContentView(content: post)
                    .presentationDetents([.large, .large])
                    .presentationDragIndicator(.hidden)
            }
            
            readOnTabNewsButton
        }
        .onDisappear {
            ttsManager.stop()
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteSheet(post: post, modelContext: modelContext)
        }
        .sheet(isPresented: $showingHighlightSheet) {
            AddHighlightSheet(post: post, modelContext: modelContext)
        }
    }
    
    // MARK: - View Builders
    
    private var postHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            PostHeaderView(post: post)
            
            PostActionsBar(
                post: post,
                postHighlights: postHighlights,
                isHighlightMode: $isHighlightMode,
                showingAddNote: $showingAddNote,
                showAudioControls: $showAudioControls
            )
            
            if showAudioControls {
                AudioControlsView(ttsManager: ttsManager, post: post)
            }
        }
    }
    
    private var postContent: some View {
        HybridMarkdownView(
            markdown: post.body ?? "",
            postId: post.id ?? "",
            highlights: postHighlights,
            isHighlightMode: isHighlightMode,
            onHighlight: { text, range in
                saveHighlight(text: text, range: range)
            },
            onRemoveHighlight: { highlight in
                removeHighlight(highlight)
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 80)
    }
    
    private var readOnTabNewsButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.showingTabNews = true
                }, label: {
                    Text("Ler no Tab News")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color.blue)
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 20)
                })
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveHighlight(text: String, range: NSRange) {
        guard let postId = post.id else { return }
        
        let highlight = Highlight(
            postId: postId,
            postTitle: post.title,
            highlightedText: text,
            note: nil,
            colorHex: HighlightColor.yellow.rawValue,
            rangeStart: range.location,
            rangeLength: range.length
        )
        
        modelContext.insert(highlight)
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        
        NotificationCenter.default.post(name: .highlightsUpdated, object: nil)
    }
    
    private func removeHighlight(_ highlight: Highlight) {
        modelContext.delete(highlight)
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.warning)
        
        NotificationCenter.default.post(name: .highlightsUpdated, object: nil)
    }
}
