# TabNews Widgets

Widgets para iOS que exibem conteúdo do TabNews na tela inicial.

## 📱 Widgets Disponíveis

### 1. Posts Recentes

- **Tamanhos:** Small, Medium, Large
- **Descrição:** Mostra os posts mais recentes do TabNews
- **Atualização:** A cada 30 minutos

### 2. Posts Relevantes

- **Tamanhos:** Medium, Large
- **Descrição:** Posts com mais tabcoins (ordenados por relevância)
- **Atualização:** A cada 1 hora
- **Destaque:** Ranking visual com badges (🥇🥈🥉)

### 3. Resumo Semanal (Digest)

- **Tamanhos:** Medium, Large
- **Descrição:** O digest da semana criado por @italosousa
- **Atualização:** A cada 6 horas
- **Destaque:** Badge especial laranja

## 🔗 Deep Links

Todos os widgets suportam deep links para abrir posts diretamente no app:

- `tabnews://home` - Abre a tela inicial
- `tabnews://post/{username}/{slug}` - Abre um post específico
- `tabnews://digest` - Abre a lista de digests

## 🔄 Sincronização de Dados

Os dados são sincronizados automaticamente através do **App Group**: `group.tabnews.com.app.tabnews-ios`

### Quando os dados são atualizados:

1. **Posts Recentes:** Quando o app busca novos posts
2. **Digest:** Quando o DigestViewModel carrega os digests
3. **Manual:** Através do `WidgetSyncManager.shared.reloadWidgets()`

## 📂 Estrutura de Arquivos

```
TabNewsWidgets/
├── TabNewsWidgets.swift          # Configuração principal dos widgets
├── TabNewsWidgetsBundle.swift    # Bundle que agrupa todos os widgets
├── WidgetDataService.swift       # Serviço de dados compartilhados
├── AppIntent.swift               # Configurações de intent (não usado)
└── WidgetViews/
    ├── SmallWidgetViews.swift    # Layouts Small
    ├── MediumWidgetViews.swift   # Layouts Medium
    └── LargeWidgetViews.swift    # Layouts Large
```

## 🎨 Personalização

### Cores

- **Azul:** Posts Recentes
- **Laranja:** Posts Relevantes e Digest
- **Gradientes:** Badges de ranking

### Fontes

- **Títulos:** `.headline`, `.title3`, `.title2`
- **Subtítulos:** `.subheadline`
- **Metadados:** `.caption`, `.caption2`

## 🧪 Testes

Para testar os widgets:

1. Build o target `TabNewsWidgets`
2. Adicione o widget na tela inicial (long press > Edit Home Screen > +)
3. Escolha "TabNews" e selecione o widget desejado

### Mock Data

Os widgets incluem dados de mock para preview e quando não há dados reais disponíveis.

## 🐛 Debug

Para debug, verifique os logs:

```swift
print("✅ [\(type(of: self))] Sincronizados \(widgetPosts.count) posts recentes com widgets")
print("🔄 [\(type(of: self))] Widgets atualizados")
```

## 📝 Notas

- Os widgets usam `TimelineProvider` para gerenciar atualizações
- Dados são armazenados em `UserDefaults` com App Group
- Deep links são tratados pelo `ContentView.handleDeepLink()`
