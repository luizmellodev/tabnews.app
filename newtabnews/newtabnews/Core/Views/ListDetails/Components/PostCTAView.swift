//
//  PostCTAView.swift
//  newtabnews
//
//  Created by Luiz Mello on 24/12/25.
//

import SwiftUI
import SwiftData

struct PostCTAView: View {
    @Environment(MainViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var folders: [Folder]
    
    let post: PostRequest
    @State private var showingFolderPicker = false
    
    private var isLiked: Bool {
        viewModel.likedList.contains(where: { $0.id == post.id })
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Divider()
                .padding(.vertical, 10)
            
            VStack(spacing: 12) {
                Text("Gostou do post?")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Salve em uma pasta ou curta para ir à sua biblioteca")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 12) {
                Button {
                    showingFolderPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                        Text("Salvar")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    if isLiked {
                        viewModel.removeContentList(content: post)
                    } else {
                        viewModel.likeContentList(content: post)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                        Text(isLiked ? "Curtido" : "Curtir")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isLiked ? Color.pink : Color.red)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                Text("Não se esqueça de abrir no TabNews e dar upvote!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Link(destination: URL(string: "https://www.tabnews.com.br/\(post.ownerUsername ?? "")/\(post.slug ?? "")")!) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Abrir no TabNews")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 20)
        .sheet(isPresented: $showingFolderPicker) {
            FolderPickerSheet(post: post, folders: folders, modelContext: modelContext)
                .id(post.id ?? UUID().uuidString)
        }
    }
}

