//
//  DigestDetailsView.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/12/25.
//

import SwiftUI

struct DigestDetailsView: View {
    let digest: PostRequest?
    @Environment(MainViewModel.self) var viewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(digest?.title ?? "Sem título")
                    .font(.title)
                    .bold()
                
                if let content = digest, let body = content.body {
                    HybridMarkdownView(
                        markdown: body,
                        postId: content.id ?? "",
                        highlights: [],
                        isHighlightMode: false,
                        onHighlight: { _, _ in },
                        onRemoveHighlight: { _ in }
                    )
                } else if digest != nil {
                    ProgressView()
                } else {
                    Text("Ops, problema pra pegar esse conteúdo")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                // Botão de CTA (Curtir/Salvar)
                if let content = digest {
                    PostCTAView(post: content)
                        .environment(viewModel)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Crédito e agradecimento
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 4) {
                        Text("Digest criado e mantido por")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Link("italosousa", destination: URL(string: "https://www.tabnews.com.br/italosousa")!)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    
                    Text("💙 Obrigado por manter a comunidade ativa e organizada!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardColor").opacity(0.5))
                )
            }
            .padding()
        }
        .navigationTitle("Resumo Semanal")
    }
}

