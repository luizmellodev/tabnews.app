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
        
        // Sempre permitir seleção para que links funcionem
        textView.isSelectable = true
        
        // Controlar se o texto pode ser selecionado pelo usuário
        // No modo normal, os links funcionam mas o usuário não pode selecionar texto
        if !isHighlightMode {
            textView.selectedTextRange = nil
        }
        
        // Criar attributed string com markdown básico
        let attributedString = processMarkdown(text)
        
        // Aplicar highlights existentes
        for highlight in highlights {
            if highlight.rangeStart >= 0 && highlight.rangeStart + highlight.rangeLength <= attributedString.length {
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
    
    private func processMarkdown(_ markdown: String) -> NSMutableAttributedString {
        var processedText = markdown
        let attributedString = NSMutableAttributedString()
        
        // Processar linha por linha para manter a estrutura
        let lines = processedText.components(separatedBy: "\n")
        var inCodeBlock = false
        
        for (index, line) in lines.enumerated() {
            var lineAttributedString = NSMutableAttributedString()
            var currentLine = line
            
            // Estilo base
            let baseParagraphStyle = NSMutableParagraphStyle()
            baseParagraphStyle.lineSpacing = 4
            
            // Headers (# ## ### etc)
            if let headerMatch = line.range(of: "^(#{1,6})\\s+(.+)$", options: .regularExpression) {
                let headerLevel = line[headerMatch].prefix(while: { $0 == "#" }).count
                let headerText = String(line.dropFirst(headerLevel).trimmingCharacters(in: .whitespaces))
                let fontSize: CGFloat = max(20, 28 - CGFloat(headerLevel * 2))
                
                lineAttributedString = NSMutableAttributedString(string: headerText)
                lineAttributedString.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: fontSize),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: baseParagraphStyle
                ], range: NSRange(location: 0, length: lineAttributedString.length))
            }
            // Divider (--- ou ***)
            else if line.trimmingCharacters(in: .whitespaces).range(of: "^(---|\\*\\*\\*)$", options: .regularExpression) != nil {
                lineAttributedString = NSMutableAttributedString(string: "―――――――――――――――――――")
                lineAttributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.separator
                ], range: NSRange(location: 0, length: lineAttributedString.length))
            }
            // Lista (- item) - apenas hífen+espaço como no MDText
            else if line.trimmingCharacters(in: .whitespaces).hasPrefix("- ") {
                let pattern = "^-\\s+(.+)"
                if let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines),
                   let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.count)) {
                    let itemRange = match.range(at: 1)
                    let itemText = (line as NSString).substring(with: itemRange)
                    
                    lineAttributedString = NSMutableAttributedString(string: "• \(itemText)")
                    let listParagraph = NSMutableParagraphStyle()
                    listParagraph.firstLineHeadIndent = 0
                    listParagraph.headIndent = 20
                    listParagraph.lineSpacing = 4
                    
                    lineAttributedString.addAttributes([
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.label,
                        .paragraphStyle: listParagraph
                    ], range: NSRange(location: 0, length: lineAttributedString.length))
                } else {
                    // Fallback
                    let itemText = String(line.dropFirst(2))
                    lineAttributedString = NSMutableAttributedString(string: "• \(itemText)")
                    lineAttributedString.addAttributes([
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.label
                    ], range: NSRange(location: 0, length: lineAttributedString.length))
                }
            }
            // Bloco de código (```...```)
            else if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                inCodeBlock.toggle()
                // Linha do marcador ``` não é mostrada
                continue
            }
            // Linha dentro de bloco de código
            else if inCodeBlock {
                lineAttributedString = NSMutableAttributedString(string: currentLine)
                lineAttributedString.addAttributes([
                    .font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                    .backgroundColor: UIColor.systemGray6,
                    .foregroundColor: UIColor.label
                ], range: NSRange(location: 0, length: lineAttributedString.length))
            }
            // Quote (> texto)
            else if line.trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                let quoteText = String(line.dropFirst().trimmingCharacters(in: .whitespaces))
                lineAttributedString = NSMutableAttributedString(string: "│ \(quoteText)")
                lineAttributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.secondaryLabel,
                    .paragraphStyle: baseParagraphStyle
                ], range: NSRange(location: 0, length: lineAttributedString.length))
            }
            // Linha normal
            else {
                lineAttributedString = NSMutableAttributedString(string: currentLine)
                lineAttributedString.addAttributes([
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: baseParagraphStyle
                ], range: NSRange(location: 0, length: lineAttributedString.length))
            }
            
            // Aplicar formatação inline (bold, italic, code, links) na linha
            applyInlineFormatting(to: lineAttributedString)
            
            attributedString.append(lineAttributedString)
            
            // Adicionar quebra de linha (exceto na última linha)
            if index < lines.count - 1 {
                attributedString.append(NSAttributedString(string: "\n"))
            }
        }
        
        return attributedString
    }
    
    private func applyInlineFormatting(to attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        // Bold (**texto** ou __texto__)
        let boldPattern = "(\\*\\*|__)(.+?)\\1"
        if let boldRegex = try? NSRegularExpression(pattern: boldPattern) {
            let matches = boldRegex.matches(in: text, range: fullRange).reversed()
            for match in matches {
                let fullMatch = match.range
                let contentRange = match.range(at: 2)
                let content = (text as NSString).substring(with: contentRange)
                
                let boldText = NSAttributedString(string: content, attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ])
                attributedString.replaceCharacters(in: fullMatch, with: boldText)
            }
        }
        
        // Italic (*texto* ou _texto_)
        let italicPattern = "(?<!\\*)\\*(?!\\*)([^*]+)\\*(?!\\*)|(?<!_)_(?!_)([^_]+)_(?!_)"
        if let italicRegex = try? NSRegularExpression(pattern: italicPattern) {
            let matches = italicRegex.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length)).reversed()
            for match in matches {
                let fullMatch = match.range
                let contentRange = match.range(at: 1).location != NSNotFound ? match.range(at: 1) : match.range(at: 2)
                let content = (attributedString.string as NSString).substring(with: contentRange)
                
                let italicText = NSAttributedString(string: content, attributes: [
                    .font: UIFont.italicSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.label
                ])
                attributedString.replaceCharacters(in: fullMatch, with: italicText)
            }
        }
        
        // Code inline (`code`)
        let codePattern = "`([^`]+)`"
        if let codeRegex = try? NSRegularExpression(pattern: codePattern) {
            let matches = codeRegex.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length)).reversed()
            for match in matches {
                let fullMatch = match.range
                let contentRange = match.range(at: 1)
                let content = (attributedString.string as NSString).substring(with: contentRange)
                
                let codeText = NSAttributedString(string: content, attributes: [
                    .font: UIFont.monospacedSystemFont(ofSize: 15, weight: .regular),
                    .backgroundColor: UIColor.systemGray5,
                    .foregroundColor: UIColor.systemPink
                ])
                attributedString.replaceCharacters(in: fullMatch, with: codeText)
            }
        }
        
        // Hyperlinks <url> - processar PRIMEIRO
        let hyperlinkPattern = "<((?i)https?://(?:www\\.)?\\S+(?:/|\\b))>"
        if let hyperlinkRegex = try? NSRegularExpression(pattern: hyperlinkPattern) {
            let matches = hyperlinkRegex.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length)).reversed()
            for match in matches {
                let fullMatch = match.range
                let urlRange = match.range(at: 1)
                let urlString = (attributedString.string as NSString).substring(with: urlRange)
                
                if let url = URL(string: urlString) {
                    let linkedText = NSAttributedString(string: urlString, attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .link: url,
                        .foregroundColor: UIColor.systemBlue,
                        .underlineStyle: NSUnderlineStyle.single.rawValue
                    ])
                    attributedString.replaceCharacters(in: fullMatch, with: linkedText)
                }
            }
        }
        
        // Autolinks (URLs soltas) - processar DEPOIS dos hyperlinks
        let autolinkPattern = "(?<!\\]\\()https?://[^\\s<>]+\\.[^\\s<>]+"
        if let autolinkRegex = try? NSRegularExpression(pattern: autolinkPattern) {
            let matches = autolinkRegex.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length)).reversed()
            for match in matches {
                let fullMatch = match.range
                let urlString = (attributedString.string as NSString).substring(with: fullMatch)
                
                if let url = URL(string: urlString) {
                    let linkedText = NSAttributedString(string: urlString, attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .link: url,
                        .foregroundColor: UIColor.systemBlue,
                        .underlineStyle: NSUnderlineStyle.single.rawValue
                    ])
                    attributedString.replaceCharacters(in: fullMatch, with: linkedText)
                }
            }
        }
        
        // Imagens ![alt](url) - processar ANTES dos links markdown
        let imagePattern = "!\\[([^\\]]*)\\]\\(([^\\)]+)\\)"
        if let imageRegex = try? NSRegularExpression(pattern: imagePattern) {
            let matches = imageRegex.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length)).reversed()
            for match in matches {
                let fullMatch = match.range
                let altRange = match.range(at: 1)
                let urlRange = match.range(at: 2)
                
                let alt = (attributedString.string as NSString).substring(with: altRange)
                let urlString = (attributedString.string as NSString).substring(with: urlRange)
                
                // Mostrar como bloco de imagem com estilo diferenciado
                let imageDisplayText = "🖼️ \(alt.isEmpty ? "Imagem" : alt)"
                
                if let url = URL(string: urlString) {
                    let imageText = NSMutableAttributedString(string: imageDisplayText, attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .link: url,
                        .foregroundColor: UIColor.systemIndigo,
                        .backgroundColor: UIColor.systemGray6
                    ])
                    attributedString.replaceCharacters(in: fullMatch, with: imageText)
                } else {
                    // Se não tiver URL válida, só mostra o texto
                    let imageText = NSAttributedString(string: imageDisplayText, attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.systemGray
                    ])
                    attributedString.replaceCharacters(in: fullMatch, with: imageText)
                }
            }
        }
        
        // Links [texto](url) - processar DEPOIS das imagens
        let linkPattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
        if let linkRegex = try? NSRegularExpression(pattern: linkPattern) {
            let matches = linkRegex.matches(in: attributedString.string, range: NSRange(location: 0, length: attributedString.length)).reversed()
            for match in matches {
                let fullMatch = match.range
                let textRange = match.range(at: 1)
                let urlRange = match.range(at: 2)
                
                let linkText = (attributedString.string as NSString).substring(with: textRange)
                let urlString = (attributedString.string as NSString).substring(with: urlRange)
                
                if let url = URL(string: urlString) {
                    let linkedText = NSAttributedString(string: linkText, attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .link: url,
                        .foregroundColor: UIColor.systemBlue,
                        .underlineStyle: NSUnderlineStyle.single.rawValue
                    ])
                    attributedString.replaceCharacters(in: fullMatch, with: linkedText)
                }
            }
        }
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
        
        // Permitir interação com links
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // Sempre permitir abrir links
            return true
        }
        
        // Controlar seleção de texto
        func textViewDidChangeSelection(_ textView: UITextView) {
            // Se não estiver no modo destaque, limpar seleção
            // (mas ainda permite cliques em links)
            if !parent.isHighlightMode, let selectedRange = textView.selectedTextRange {
                // Verificar se há texto selecionado (não é apenas o cursor)
                if !selectedRange.isEmpty {
                    textView.selectedTextRange = nil
                }
            }
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


