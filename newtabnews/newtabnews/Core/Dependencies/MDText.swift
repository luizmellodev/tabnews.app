//
//  MDText.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import SwiftUI
import Combine
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

protocol MarkdownRule {
    var id: String { get }
    var regex: RegexMarkdown { get }
    //    func replace(_ text: String) -> Text
}

struct MDTextGroup {
    var string: String
    var rules: [MarkdownRule]
    var applicableRules: [MarkdownRule] {
        rules.filter{$0.regex != BaseMarkdownRules.none.regex}
    }
    var text: Text {
        guard let firstRule = applicableRules.first else { 
            return Text(string) 
        }
        
        // Limpa o texto primeiro (remove marcadores)
        var cleanedString = string
        for rule in applicableRules {
            cleanedString = rule.regex.outputString(for: cleanedString)
        }
        
        // Depois aplica os estilos no texto limpo
        return applicableRules.reduce(Text(cleanedString)) { text, rule in
            rule.regex.strategy(text)
        }
    }
    
    var viewType: MDViewType {
        // Check for image first
        if applicableRules.contains(where: { $0.id == BaseMarkdownRules.image.id }) {
            let (url, alt) = extractImageInfo()
            return .image(url, alt)
        }
        
        // Check for divider
        if applicableRules.contains(where: { $0.id == BaseMarkdownRules.divider.id }) {
            return .divider
        }
        
        // Check for list item
        if applicableRules.contains(where: { $0.id == BaseMarkdownRules.listItem.id }) {
            return .listItem(self.text)
        }
        
        // Check for link
        if applicableRules.contains(where: { $0.id == BaseMarkdownRules.link.id || $0.id == BaseMarkdownRules.hyperlink.id || $0.id == BaseMarkdownRules.autolink.id }) {
            return .link(self)
        }
        
        return .text(self.text)
    }
    
    func extractImageInfo() -> (String, String?) {
        // Extract URL and alt text from ![alt](url) or ![alt](url "title")
        let pattern = #"!\[([^\]]*)\]\(([^\)]+)\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return ("", nil)
        }
        
        let nsString = string as NSString
        guard let match = regex.firstMatch(in: string, range: NSRange(location: 0, length: nsString.length)) else {
            return ("", nil)
        }
        
        let alt = match.range(at: 1).location != NSNotFound ? nsString.substring(with: match.range(at: 1)) : nil
        var urlPart = match.range(at: 2).location != NSNotFound ? nsString.substring(with: match.range(at: 2)) : ""
        
        // Remove o título se houver (tudo depois de espaços + " )
        if let quoteIndex = urlPart.range(of: #"\s+"#, options: .regularExpression) {
            urlPart = String(urlPart[..<quoteIndex.lowerBound])
        }
        
        // Limpa espaços
        let url = urlPart.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (url, alt)
    }
    
    var urlStr: String {
        RegexMarkdown.url(for: string)
    }
    
}

enum MDViewType {
    case text(Text), link(MDTextGroup), image(String, String?), divider, listItem(Text)
}

struct MDViewGroup: Identifiable {
    let id = UUID()
    var type: MDViewType
    var view: some View {
        switch type {
        case .link(let group):
            return Button(action: {self.onLinkTap(urlStr: group.urlStr)}, label: {group.text})
                .buttonStyle(PlainButtonStyle())
                .ereaseToAnyView()
        case .text(let text):
            return text
                .fixedSize(horizontal: false, vertical: true)
                .ereaseToAnyView()
        case .image(let urlString, let alt):
            return VStack(alignment: .leading, spacing: 8) {
                // Limpa e valida a URL
                let cleanedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Cria URL (AsyncImage aceita URLs sem scheme validado)
                if let url = URL(string: cleanedURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Carregando...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(8)
                                
                        case .failure:
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.orange)
                                    Text("Erro ao carregar imagem")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(cleanedURL)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // URL inválida
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                            Text("URL inválida")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(cleanedURL)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if let altText = alt, !altText.isEmpty {
                    Text(altText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.horizontal, 4)
                }
            }
            .padding(.vertical, 8)
            .ereaseToAnyView()
        case .divider:
            return Divider()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .ereaseToAnyView()
        case .listItem(let text):
            return HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .fontWeight(.bold)
                text
                Spacer()
            }
            .padding(.leading, 8)
            .ereaseToAnyView()
        }
    }
    
    func onLinkTap(urlStr: String) {
        print(urlStr)
        guard let url = URL(string: urlStr) else { return }
        #if os(iOS)
        UIApplication.shared.open(url, options: [:])
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}


struct RegexMarkdown: Equatable {
    static func == (lhs: RegexMarkdown, rhs: RegexMarkdown) -> Bool {
        lhs.matchIn == rhs.matchIn && lhs.matchOut == rhs.matchOut
    }
    
    var matchIn: String
    var matchOut: String
    var strategy: (Text) -> Text
    func output(for string: String) -> Text {
        let result = outputString(for: string)
        let text = Text(result)
        return strategy(text)
    }
    
    func outputString(for string: String) -> String {
        guard !matchIn.isEmpty else {
            return string
        }
        return string.replacingOccurrences(of: self.matchIn, with: self.matchOut, options: .regularExpression)
    }
    
    static func url(for string: String) -> String {
        let matcher = try! NSRegularExpression(pattern: #"((http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*))"#)
        guard let match = matcher.firstMatch(in: string, range: NSRange(location: 0, length: string.utf16.count)) else { return ""}
        let result = string[Range(match.range, in: string)!]
        print(result)
        return String(result)
    }
}

extension RegexMarkdown {
    private var matcher: NSRegularExpression {
        return try! NSRegularExpression(pattern: self.matchIn)
        
    }
    func match(string: String, options: NSRegularExpression.MatchingOptions = .init()) -> Bool {
        return self.matcher.numberOfMatches(in: string, options: options, range: NSMakeRange(0, string.utf16.count)) != 0
    }
}

enum BaseMarkdownRules: String, CaseIterable, MarkdownRule {
    
    
    case none, header, header2, header3, header4, image, divider, listItem, bold, link, autolink, hyperlink, emphasis
    var id: String { self.rawValue }
    //
    //    , , del, quote, inline, ul, ol, blockquotes
    
    var regex: RegexMarkdown {
        switch self {
        case .header:
            return .init(matchIn: #"^#\s+(.+)"#, matchOut: "$1", strategy: self.header1(_:))
        case .header2:
            return .init(matchIn: #"^##\s+(.+)"#, matchOut: "$1", strategy: self.header2(_:))
        case .header3:
            return .init(matchIn: #"^###\s+(.+)"#, matchOut: "$1", strategy: self.header3(_:))
        case .header4:
            return .init(matchIn: #"^####\s+(.+)"#, matchOut: "$1", strategy: self.header4(_:))
        case .image:
            return .init(matchIn: #"!\[([^\]]*)\]\(([^\)]+)\)"#, matchOut: "", strategy: {$0})
        case .divider:
            return .init(matchIn: #"^---+\s*$"#, matchOut: "", strategy: {$0})
        case .listItem:
            return .init(matchIn: #"^-\s+(.+)"#, matchOut: "$1", strategy: {$0})
        case .bold:
            return .init(matchIn: "\\*\\*([^*]+?)\\*\\*", matchOut: "$1", strategy: self.bold(_:))
        case .link:
            return .init(matchIn: #"\[([^\[]+)\]\(([^\)]+)\)"#, matchOut: "$1", strategy: self.link(_:))
        case .autolink:
            return .init(matchIn: "(?<!\\]\\()https?://[^\\s<>]+\\.[^\\s<>]+", matchOut: "$0", strategy: self.link(_:))
        case .hyperlink:
            return .init(matchIn: "<((?i)https?://(?:www\\.)?\\S+(?:/|\\b))>", matchOut: "$1", strategy: self.link(_:))
        case .emphasis:
            return .init(matchIn: "(?<!\\*)\\*([^*]+?)\\*(?!\\*)", matchOut: "$1", strategy: self.emphasis(_:))
        case .none:
            return .init(matchIn: "", matchOut: "", strategy: {$0})
        }
    }
    
    func header1(_ text: Text) -> Text {
        return text.font(.title).fontWeight(.bold).foregroundColor(.primary)
    }
    
    func header2(_ text: Text) -> Text {
        return text.font(.title2).fontWeight(.semibold).foregroundColor(.primary)
    }
    
    func header3(_ text: Text) -> Text {
        return text.font(.title3).fontWeight(.semibold).foregroundColor(.primary)
    }
    
    func header4(_ text: Text) -> Text {
        return text.font(.headline).fontWeight(.semibold).foregroundColor(.primary)
    }
    
    func link(_ text: Text) -> Text {
        return text.foregroundColor(.blue).underline()
    }
    
    func bold(_ text: Text) -> Text {
        return text.bold()
    }
    
    func emphasis(_ text: Text) -> Text {
        return text.italic()
    }
}

func onTapLink(url: String) {
    
}


//    var rules: [String : ((String) -> AnyView))] {
//        [
//            #"/(#+)(.*)/"# -> self.header,                           // headers
//        #"/\[([^\[]+)\]\(([^\)]+)\)/"# -> '<a href=\'\2\'>\1</a>',  // links
//        #"/(\*\*|__)(.*?)\1/"# -> '<strong>\2</strong>',            // bold
//        #"/(\*|_)(.*?)\1/"# -> '<em>\2</em>',                       // emphasis
//        #"/\~\~(.*?)\~\~/"# -> '<del>\1</del>',                     // del
//        #"/\:\"(.*?)\"\:/"# -> '<q>\1</q>',                         // quote
//        #"/`(.*?)`/"# -> '<code>\1</code>',                         // inline code
//        #"/\n\*(.*)/"# -> 'self::ul_list',                          // ul lists
//        #"/\n[0-9]+\.(.*)/"# -> 'self::ol_list',                    // ol lists
//        #"/\n(&gt;|\>)(.*)/"# -> 'self::blockquote ',               // blockquotes
//        #"/\n-{5,}/"# -> "\n<hr />",                                // horizontal rule
//        #"/\n([^\n]+)\n/"# -> 'self::para',                         // add paragraphs
//        #"/<\/ul>\s?<ul>/"# -> '',                                  // fix extra ul
//        #"/<\/ol>\s?<ol>/"# -> '',                                  // fix extra ol
//        #"/<\/blockquote><blockquote>/"# -> "\n"                    // fix extra blockquote
//        ]
//    }

final class MDTextVM: ObservableObject {
    
    @Published var finalText = Text("")
    
    var cancellable: Cancellable? = nil { didSet{ oldValue?.cancel() } }
    
    func parse(string: String, for markdownRules: [MarkdownRule]) {
        let firstGroup = MDTextGroup(string: string, rules: [BaseMarkdownRules.none])
        cancellable = Just(markdownRules)
            .map{ rules -> [MDTextGroup] in
                rules.reduce([firstGroup]) { (result, rule) -> [MDTextGroup] in
                    return result.flatMap{ self.replace(group: $0, for: rule)}
                }
        }
        .map { textGroups in
            textGroups.map{ $0.text}.reduce(Text(""), +)
        }
        .receive(on: RunLoop.main)
        .assign(to: \.finalText, on: self)
    }
    
    func parseText(string: String, for markdownRules: [MarkdownRule]) -> Text {
        let firstGroup = MDTextGroup(string: string, rules: [BaseMarkdownRules.none])
        let textGroups = markdownRules.reduce([firstGroup]) { (result, rule) -> [MDTextGroup] in
            return result.flatMap{ self.replace(group: $0, for: rule)}
        }
        return textGroups.map{ $0.text}.reduce(Text(""), +)
    }
    
    func parseViews(string: String, for markdownRules: [MarkdownRule]) -> [MDViewGroup] {
        let firstGroup = MDTextGroup(string: string, rules: [BaseMarkdownRules.none])
        let textGroups = markdownRules.reduce([firstGroup]) { (result, rule) -> [MDTextGroup] in
            return result.flatMap{ self.replace(group: $0, for: rule)}
        }
        
        guard let firstViewGroup = textGroups.first?.viewType else { return [] }
        
        let allViewGroups = textGroups.dropFirst().reduce([MDViewGroup(type: firstViewGroup)]) { (viewGroups, textGroup) -> [MDViewGroup] in
            let previous = viewGroups.last!
            if case .text(let previousText) = previous.type, case .text(let currentText) = textGroup.viewType {
                let updatedText = previousText + currentText
                return viewGroups.dropLast() + [MDViewGroup(type: .text(updatedText))]
            } else {
                return viewGroups + [MDViewGroup(type: textGroup.viewType)]
            }
            // if previous is just text
        }
        return allViewGroups
    }
    
    func replaceLInk(for textGroup: MDTextGroup) -> AnyView {
        return Button(action: {
            guard let url = URL(string: textGroup.string) else { return }
            #if os(iOS)
            UIApplication.shared.open(url, options: [:])
            #elseif os(macOS)
            NSWorkspace.shared.open(url)
            #endif
        }, label: {textGroup.text})
            .ereaseToAnyView()
        //
        //        return textGroup.text.onTapGesture {
        //                        guard let url = URL(string: textGroup.string) else { return }
        //                        UIApplication.shared.open(url, options: [:])
        //        }.ereaseToAnyView()
    }
    
    func replace(group: MDTextGroup, for rule: MarkdownRule) -> [MDTextGroup] {
        let string = group.string
        guard let regex = try? NSRegularExpression(pattern: rule.regex.matchIn)
            else {
                return [group]
        }
        let matches = regex.matches(in: string, range: NSRange(0..<string.utf16.count))
        let ranges = matches.map{ $0.range}
        guard !ranges.isEmpty else {
            return [group]
        }
        let zippedRanges = zip(ranges.dropFirst(), ranges)
        // TODO: pass parent modifiers to children, just create a func in mdtextgroup
        let beforeMatchesGroup = ranges.first.flatMap { range -> [MDTextGroup] in
            let lowerBound = String.Index(utf16Offset: 0, in: string)
            let upperBound = String.Index(utf16Offset: range.lowerBound, in: string)
            
            let nonMatchStr = String(string[lowerBound..<upperBound])
            return [MDTextGroup(string: nonMatchStr, rules: group.rules)]
            } ?? []
        
        let resultGroups: [MDTextGroup] =  zippedRanges.flatMap{ (next, current) -> [MDTextGroup] in
            guard let range = Range(current, in: string) else { return [] }
            let matchStr = String(string[range])

            let lowerBound = String.Index(utf16Offset: current.upperBound, in: string)
            let upperBound = String.Index(utf16Offset: next.lowerBound, in: string)
            
            let nonMatchStr = String(string[lowerBound..<upperBound])
            let groups = [MDTextGroup(string: matchStr, rules: group.rules + [rule]), MDTextGroup(string: nonMatchStr, rules: group.rules)]
            return groups
        }
        
        let lastMatch = ranges.last.flatMap{ range -> [MDTextGroup] in
            guard let index = Range(range, in: string) else { return [] }
            let matchStr = String(string[index])
            return [MDTextGroup(string: matchStr, rules: group.rules + [rule])]
            } ?? []
        
        let afterMatchesGroup = ranges.last.flatMap { range -> [MDTextGroup] in
            let lowerBound = String.Index(utf16Offset: range.upperBound, in: string)
            let upperBound = string.endIndex
            
            if upperBound <= lowerBound { // basically if it ends with a match.
                return []
            }
            
            let nonMatchStr = String(string[lowerBound..<upperBound])
            return [MDTextGroup(string: nonMatchStr, rules: group.rules)]
            } ?? []
        
        
        let completeGroups = beforeMatchesGroup + resultGroups + lastMatch + afterMatchesGroup
        return completeGroups
    }
    
}





public struct MDText: View, Equatable {
    public static func == (lhs: MDText, rhs: MDText) -> Bool {
        lhs.markdown == rhs.markdown
    }
    
    var markdown: String
    var alignment: HorizontalAlignment
    
    var rules: [MarkdownRule] = BaseMarkdownRules.allCases
    
    @ObservedObject var vm = MDTextVM()
    
    public init(markdown: String, alignment: HorizontalAlignment = .leading) {
        self.markdown = markdown
        self.alignment = alignment
    }
    
    var views: [MDViewGroup] {
        // Primeiro, junta linhas de imagens quebradas
        let fixedMarkdown = fixMultilineImages(markdown)
        
        // Process markdown line by line
        let lines = fixedMarkdown.components(separatedBy: .newlines)
        var allViews: [MDViewGroup] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines
            if trimmed.isEmpty {
                allViews.append(MDViewGroup(type: .text(Text(""))))
                continue
            }
            
            // Skip HTML comments
            if trimmed.hasPrefix("<!--") {
                continue
            }
            
            // Check for block elements first (headers, images, dividers, lists)
            if trimmed.hasPrefix("#") {
                // É um header
                let lineViews = vm.parseViews(string: line, for: rules)
                allViews.append(contentsOf: lineViews)
            } else if trimmed.hasPrefix("![") {
                // É uma imagem - extrai DIRETAMENTE sem passar pelo parseViews
                let (url, alt) = MDTextGroup(string: line, rules: []).extractImageInfo()
                if !url.isEmpty {
                    allViews.append(MDViewGroup(type: .image(url, alt)))
                } else {
                    // Fallback - tenta processar normalmente
                    let lineViews = vm.parseViews(string: line, for: rules)
                    allViews.append(contentsOf: lineViews)
                }
            } else if trimmed.hasPrefix("---") {
                // É um divider
                let lineViews = vm.parseViews(string: line, for: rules)
                allViews.append(contentsOf: lineViews)
            } else if trimmed.hasPrefix("- ") {
                // É uma lista
                let lineViews = vm.parseViews(string: line, for: rules)
                allViews.append(contentsOf: lineViews)
            } else {
                // É texto normal/inline
                let lineViews = vm.parseViews(string: line, for: rules)
                
                // Mescla todos os textos inline em um único
                if lineViews.count == 1 {
                    allViews.append(contentsOf: lineViews)
                } else {
                    // Múltiplos elementos - combina textos
                    let combinedText = lineViews.map { view -> Text in
                        switch view.type {
                        case .text(let t): return t
                        case .link(let g): return g.text
                        default: return Text("")
                        }
                    }.reduce(Text(""), +)
                    
                    allViews.append(MDViewGroup(type: .text(combinedText)))
                }
            }
        }
        
        return allViews
    }
    
    // Junta linhas de imagens que foram quebradas
    private func fixMultilineImages(_ text: String) -> String {
        var result = text
        
        // Pattern para detectar ![alt]( sem fechar no mesmo linha
        let pattern = #"!\[([^\]]*)\]\(\s*\n\s*([^\)]+)\)"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: "![$1]($2)"
            )
        }
        
        return result
    }
    
    public var body: some View {
        VStack(alignment: alignment, spacing: 6) {
            ForEach(self.views, id: \.id) { viewGroup in
                // Elementos block ocupam toda linha, inline ficam juntos
                if case .divider = viewGroup.type {
                    viewGroup.view
                } else if case .image = viewGroup.type {
                    viewGroup.view
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        viewGroup.view
                        Spacer()
                    }
                }
            }
        }
    }
}

extension View {
    func ereaseToAnyView() -> AnyView {
        AnyView(self)
    }
}


