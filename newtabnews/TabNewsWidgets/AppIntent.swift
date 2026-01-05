//
//  AppIntent.swift
//  TabNewsWidgets
//
//  Created by Luiz Mello on 04/01/26.
//

import WidgetKit
import AppIntents

// MARK: - Widget Configuration Intent

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuração do Widget" }
    static var description: IntentDescription { "Escolha o tipo de conteúdo a exibir" }

    @Parameter(title: "Tipo de Conteúdo", default: .recent)
    var contentType: WidgetContentType
}

// MARK: - Content Type Enum

enum WidgetContentType: String, AppEnum {
    case recent = "recent"
    case relevant = "relevant"
    case digest = "digest"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Tipo de Conteúdo"
    }
    
    static var caseDisplayRepresentations: [WidgetContentType: DisplayRepresentation] {
        [
            .recent: DisplayRepresentation(
                title: "Posts Recentes",
                subtitle: "Últimos posts do TabNews",
                image: .init(systemName: "newspaper.fill")
            ),
            .relevant: DisplayRepresentation(
                title: "Posts Relevantes",
                subtitle: "Posts com mais tabcoins",
                image: .init(systemName: "flame.fill")
            ),
            .digest: DisplayRepresentation(
                title: "Resumo Semanal",
                subtitle: "Digest da semana",
                image: .init(systemName: "star.fill")
            )
        ]
    }
}
