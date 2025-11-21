//
//  HighlightableTextView.swift
//  newtabnews
//
//  Created by Luiz Mello on 19/11/25.
//

import SwiftUI
import SwiftData
import UIKit

struct HighlightableTextView: UIViewRepresentable {
    let text: String
    let postId: String
    let highlights: [Highlight]
    let isHighlightMode: Bool
    let onHighlight: (String, NSRange) -> Void
    let onRemoveHighlight: (Highlight) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.delegate = context.coordinator
        
        // Permitir seleção de texto
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        
        // Configurar para ajustar ao conteúdo
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.parent = self
        
        // Criar attributed string com o texto
        let attributedString = NSMutableAttributedString(string: text)
        
        // Estilo base
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributedString.length))
        
        // Aplicar highlights existentes
        for highlight in highlights {
            if highlight.rangeStart >= 0 && highlight.rangeStart + highlight.rangeLength <= text.count {
                let range = NSRange(location: highlight.rangeStart, length: highlight.rangeLength)
                attributedString.addAttribute(
                    .backgroundColor,
                    value: UIColor(Color(hex: highlight.colorHex)).withAlphaComponent(0.4),
                    range: range
                )
            }
        }
        
        textView.attributedText = attributedString
        
        // Invalidar layout para recalcular altura
        textView.invalidateIntrinsicContentSize()
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? UIScreen.main.bounds.width - 60 // Padding horizontal
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: size.height)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightableTextView
        
        init(_ parent: HighlightableTextView) {
            self.parent = parent
        }
        
        // Customizar o menu de contexto
        func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
            let selectedText = (textView.text as NSString).substring(with: range)
            
            // Verificar se o texto selecionado está em um highlight existente
            let existingHighlight = parent.highlights.first { highlight in
                let highlightRange = NSRange(location: highlight.rangeStart, length: highlight.rangeLength)
                return NSIntersectionRange(range, highlightRange).length > 0
            }
            
            var actions: [UIMenuElement] = []
            
            // Se está no modo highlight, mostrar opção de destacar
            if parent.isHighlightMode {
                let highlightAction = UIAction(
                    title: "✨ Destacar",
                    image: UIImage(systemName: "highlighter")
                ) { [weak self] _ in
                    self?.parent.onHighlight(selectedText, range)
                    textView.selectedTextRange = nil
                }
                actions.append(highlightAction)
            }
            
            // Se há um highlight existente, mostrar opção de remover
            if let highlight = existingHighlight {
                let removeAction = UIAction(
                    title: "🗑️ Remover Destaque",
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.parent.onRemoveHighlight(highlight)
                    textView.selectedTextRange = nil
                }
                actions.append(removeAction)
            }
            
            guard !actions.isEmpty else { return nil }
            
            return UIMenu(title: "", children: actions)
        }
    }
}

