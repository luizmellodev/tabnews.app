//
//  AddFolderSheet.swift
//  newtabnews
//
//  Created by Luiz Mello on 20/11/25.
//

import SwiftUI
import SwiftData

struct AddFolderSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var folderName = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "#007AFF"
    
    let iconOptions = [
        "folder.fill", "star.fill", "heart.fill", "bookmark.fill",
        "flag.fill", "tag.fill", "paperclip", "briefcase.fill",
        "book.fill", "graduationcap.fill", "lightbulb.fill", "brain.head.profile"
    ]
    
    let colorOptions = [
        ("Azul", "#007AFF"),
        ("Vermelho", "#FF3B30"),
        ("Verde", "#34C759"),
        ("Laranja", "#FF9500"),
        ("Roxo", "#AF52DE"),
        ("Rosa", "#FF2D55"),
        ("Azul Claro", "#5AC8FA"),
        ("Amarelo", "#FFCC00")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Nome") {
                    TextField("Ex: Desenvolvimento Web", text: $folderName)
                }
                
                Section("Ícone") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .white : .primary)
                                        .frame(width: 50, height: 50)
                                        .background(selectedIcon == icon ? Color.accentColor : Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Cor") {
                    ForEach(colorOptions, id: \.1) { name, hex in
                        Button {
                            selectedColor = hex
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 24, height: 24)
                                
                                Text(name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedColor == hex {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nova Pasta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        createFolder()
                    }
                    .disabled(folderName.isEmpty)
                }
            }
        }
    }
    
    private func createFolder() {
        let folder = Folder(name: folderName, icon: selectedIcon, colorHex: selectedColor)
        modelContext.insert(folder)
        
        NotificationCenter.default.post(name: .foldersUpdated, object: nil)
        
        GamificationManager.shared.trackFolderCreated()
        
        dismiss()
    }
}

