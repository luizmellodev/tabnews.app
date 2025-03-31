//
//  SearchBar.swift
//  newtabnews
//
//  Created by Luiz Mello on 22/07/23.
//

import SwiftUI

struct SearchBar: View {

    // MARK: - PROPERTY WRAPPERS
    @Binding var searchText: String
    @Binding var isSearching: Bool

    // MARK: - VARIABLES
    var searchPlaceHolder: String
    var searchCancel: String

    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .animation(.easeInOut, value: isSearching)
                    
                    TextField(searchPlaceHolder, text: $searchText)
                        .focused($isFocused)
                        .foregroundColor(Color.primary)
                        .submitLabel(.search)
                    
                    if !searchText.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                searchText = ""
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("CardColor"))
                        .contentShape(Rectangle())
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = true
                        isFocused = true
                    }
                }
                
                if isSearching {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSearching = false
                            isFocused = false
                            searchText = ""
                        }
                    } label: {
                        Text(searchCancel)
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 8)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if isSearching {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSearching = false
                            isFocused = false
                            searchText = ""
                        }
                    }
            }
        }
        .onChange(of: isFocused) { newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                isSearching = newValue
            }
        }
    }
}
