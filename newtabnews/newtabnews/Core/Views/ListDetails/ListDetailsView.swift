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
    @Query private var highlights: [Highlight]
    
    private var postHighlights: [Highlight] {
        highlights.filter { $0.postId == post.id }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.title ?? "Título indisponível :/")
                            .padding(.top, 30)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        // Barra de ações
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Botão TTS
                                Button {
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    ttsManager.togglePlayPause(
                                        text: post.body ?? "",
                                        title: post.title
                                    )
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: ttsManager.isPlaying ? "pause.circle" : "speaker.wave.2")
                                        Text(ttsManager.isPlaying ? "Pausar" : "Ouvir")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Botão Destacar
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
                                        } else if !postHighlights.isEmpty {
                                            Text("\(postHighlights.count)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text("Destacar")
                                                .font(.caption)
                                        }
                                    }
                                    .foregroundColor(isHighlightMode ? .green : (postHighlights.isEmpty ? .yellow : .orange))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background((isHighlightMode ? Color.green : (postHighlights.isEmpty ? Color.yellow : Color.orange)).opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Botão Anotar
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
                                
                                // Botão de Like
                                Button {
                                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                    impactHeavy.impactOccurred()
                                    
                                    if viewModel.likedList.contains(where: { $0.title == post.title }) {
                                        viewModel.removeContentList(content: post)
                                    } else {
                                        viewModel.likeContentList(content: post)
                                    }
                                } label: {
                                    Image(systemName: viewModel.likedList.contains(where: { $0.title == post.title }) ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.likedList.contains(where: { $0.title == post.title }) ? .red : .gray)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.bottom, 4)
                    }
                    HStack {
                        Text(post.ownerUsername ?? "luizmellodev")
                            .font(.footnote)
                        Spacer()
                        Text(getFormattedDate(value: post.createdAt ?? "sábado-feira, 31 fevereiro"))
                            .font(.footnote)
                            .italic()
                    }
                    .foregroundColor(.gray)
                    Divider()
                    
                    // Indicador visual do modo highlight
                    if isHighlightMode {
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
                    
                    // Texto sempre selecionável com highlights visíveis
                    HighlightableTextView(
                        text: post.body ?? "",
                        postId: post.id ?? "",
                        highlights: postHighlights,
                        isHighlightMode: isHighlightMode,
                        onHighlight: { selectedText, range in
                            saveHighlight(text: selectedText, range: range)
                        },
                        onRemoveHighlight: { highlight in
                            removeHighlight(highlight)
                        }
                    )
                    .padding(.bottom, 80)
                }
                .padding(.horizontal, 30)
            }
            .sheet(isPresented: $showingTabNews) {
                WebContentView(content: post)
                    .presentationDetents([.large, .large])
                    .presentationDragIndicator(.hidden)
            }
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
        .onDisappear {
            // Parar o TTS quando sair da view
            ttsManager.stop()
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteSheet(post: post, modelContext: modelContext)
        }
        .sheet(isPresented: $showingHighlightSheet) {
            AddHighlightSheet(post: post, modelContext: modelContext)
        }
    }
    
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
        
        // Feedback háptico
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
    }
    
    private func removeHighlight(_ highlight: Highlight) {
        modelContext.delete(highlight)
        
        // Feedback háptico
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.warning)
    }
}

// Sheet para adicionar anotação
struct AddNoteSheet: View {
    let post: PostRequest
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var noteText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(post.title ?? "")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Section("Sua Anotação") {
                    TextEditor(text: $noteText)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("Nova Anotação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveNote()
                    }
                    .disabled(noteText.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        guard let postId = post.id else { return }
        
        let note = Note(
            postId: postId,
            postTitle: post.title,
            content: noteText
        )
        
        modelContext.insert(note)
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        
        dismiss()
    }
}

// Sheet para adicionar highlight
struct AddHighlightSheet: View {
    let post: PostRequest
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedText = ""
    @State private var highlightNote = ""
    @State private var selectedColor = HighlightColor.yellow
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(post.title ?? "")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Section("Selecione o Texto") {
                    TextEditor(text: $selectedText)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if selectedText.isEmpty {
                                Text("Cole ou digite o trecho que deseja destacar")
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                
                Section("Cor do Destaque") {
                    ForEach(HighlightColor.allCases, id: \.self) { color in
                        Button {
                            selectedColor = color
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(hex: color.rawValue))
                                    .frame(width: 24, height: 24)
                                
                                Text(color.displayName)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedColor == color {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
                
                Section("Nota (Opcional)") {
                    TextEditor(text: $highlightNote)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Novo Destaque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveHighlight()
                    }
                    .disabled(selectedText.isEmpty)
                }
            }
        }
    }
    
    private func saveHighlight() {
        guard let postId = post.id else { return }
        
        let highlight = Highlight(
            postId: postId,
            postTitle: post.title,
            highlightedText: selectedText,
            note: highlightNote.isEmpty ? nil : highlightNote,
            colorHex: selectedColor.rawValue,
            rangeStart: 0,
            rangeLength: selectedText.count
        )
        
        modelContext.insert(highlight)
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        
        dismiss()
    }
}
