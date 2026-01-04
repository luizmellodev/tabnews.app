//
//  SettingsView.swift
//  tabnewsios
//
//  Created by Luiz Eduardo Mello dos Reis on 31/12/22.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(MainViewModel.self) var viewModel
    @Query private var folders: [Folder]
    @Query private var highlights: [Highlight]
    @Query private var notes: [Note]
    
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    
    @State private var showingClearCache = false
    @State private var showingClearLibrary = false
    @State private var showAuthSheet = false
    @State private var showLogoutAlert = false
    @StateObject private var authService = AuthService.shared
    @AppStorage("debugShowDigestBanner") private var debugShowDigestBanner = false
    @AppStorage("showReadOnTabNewsButton") private var showReadOnTabNewsButton = false
    
    var body: some View {
        NavigationStack {
            List {
                // Seção de Perfil/Conta
                Section {
                    profileSection
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
                .listRowSeparator(.hidden)
                
                // Aparência
                    Section {
                        Picker("Tema", selection: $currentTheme) {
                            Label("Sistema", systemImage: "iphone").tag(Theme.system)
                            Label("Claro", systemImage: "sun.max").tag(Theme.light)
                            Label("Escuro", systemImage: "moon").tag(Theme.dark)
                        }
                        .pickerStyle(.menu)
                    } header: {
                        Label("Aparência", systemImage: "paintbrush")
                    }
                    
                    // Leitura
                    Section {
                        Toggle(isOn: $isViewInApp) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Visualizar no App")
                                Text("Abrir posts dentro do aplicativo")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Toggle(isOn: $showReadOnTabNewsButton) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Botão 'Ler no TabNews'")
                                Text("Mostra botão flutuante para abrir no Safari")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Label("Leitura", systemImage: "book")
                    } footer: {
                        Text("O botão flutuante permite abrir o post no navegador. Desativado por padrão para melhor experiência nativa.")
                    }
                
                // Estatísticas
                Section {
                    HStack {
                        Label("Posts Curtidos", systemImage: "heart")
                        Spacer()
                        Text("\(viewModel.likedList.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Destaques", systemImage: "highlighter")
                        Spacer()
                        Text("\(highlights.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Anotações", systemImage: "note.text")
                        Spacer()
                        Text("\(notes.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Pastas Criadas", systemImage: "folder")
                        Spacer()
                        Text("\(folders.count)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Sua Biblioteca", systemImage: "chart.bar")
                }
                
                // Ajuda
                Section {
                    Button {
                        UserDefaults.standard.set(false, forKey: "hasSeenTipsOnboarding")
                        NotificationCenter.default.post(name: .showTipsOnboarding, object: nil)
                    } label: {
                        Label("Ver Dicas Novamente", systemImage: "lightbulb.fill")
                    }
                    
                    Button {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                        UserDefaults.standard.set(false, forKey: "hasSeenTipsOnboarding")
                        // Reiniciar o app para mostrar o onboarding completo
                        exit(0)
                    } label: {
                        Label("Resetar Onboarding Completo", systemImage: "arrow.counterclockwise.circle")
                    }
                } header: {
                    Label("Ajuda", systemImage: "questionmark.circle")
                } footer: {
                    Text("Ver dicas: mostra apenas as dicas contextuais. Resetar completo: reinicia o app e mostra todo o onboarding inicial + dicas.")
                }
                
                // Notificações
                Section {
                    HStack {
                        Label("Status das Notificações", systemImage: "bell.badge")
                        Spacer()
                        Text(NotificationManager.shared.isPermissionGranted ? "Ativadas" : "Desativadas")
                            .foregroundStyle(NotificationManager.shared.isPermissionGranted ? .green : .secondary)
                    }
                    
                    if !NotificationManager.shared.isPermissionGranted {
                        Button {
                            // Abrir configurações do app
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Abrir Configurações do App", systemImage: "gear")
                        }
                    }
                } header: {
                    Label("Notificações", systemImage: "bell")
                } footer: {
                    Text("Receba notificações de novas newsletters e resumos semanais do TabNews")
                }
                
                // Dados
                Section {
                    Button(role: .destructive) {
                        showingClearCache = true
                    } label: {
                        Label("Limpar Cache da API", systemImage: "arrow.clockwise.circle")
                    }
                    
                    Button(role: .destructive) {
                        showingClearLibrary = true
                    } label: {
                        Label("Limpar Biblioteca Completa", systemImage: "trash.fill")
                    }
                } header: {
                    Label("Dados", systemImage: "internaldrive")
                } footer: {
                    Text("O cache força atualização dos posts. Limpar a biblioteca remove TUDO (curtidas, destaques, anotações e pastas)")
                }
                
                // Sobre
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sobre o App")
                            .font(.headline)
                        
                        Text("Este é um aplicativo não-oficial do TabNews, criado por um entusiasta da comunidade. O objetivo é facilitar o acesso ao conteúdo e permitir organização pessoal através de destaques e anotações.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Criadores
                Section {
                    NavigationLink {
                        SocialView(
                            github: "filipedeschamps",
                            linkedin: "filipedeschamps",
                            youtube: "FilipeDeschamps",
                            instagram: "filipedeschamps"
                        )
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Felipe Deschamps")
                                    .font(.headline)
                                Text("Criador do TabNews")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink {
                        SocialView(
                            github: "luizmellodev",
                            linkedin: "luizmellodev",
                            youtube: "",
                            instagram: "luizmello.dev"
                        )
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Luiz Mello")
                                    .font(.headline)
                                Text("Desenvolvedor deste app")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Label("Criadores", systemImage: "person.2")
                }
                
                // Debug (só aparece em desenvolvimento)
                #if DEBUG
                Section {
                    // Info sobre tempo
                    HStack {
                        Text("Tempo no app")
                            .font(.caption)
                        Spacer()
                        Text(AppUsageTracker.shared.formattedTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Botões de jogo
                    Button {
                        AppUsageTracker.shared.shouldShowGameButton = true
                        UserDefaults.standard.set(true, forKey: "hasShownGameButton")
                    } label: {
                        Label("🕹️ Forçar Botão de Jogo", systemImage: "gamecontroller")
                    }
                    
                    Button {
                        AppUsageTracker.shared.shouldShowRestFolder = true
                        UserDefaults.standard.set(true, forKey: "hasShownRestFolder")
                    } label: {
                        Label("🎮 Forçar Pasta 'Descanse'", systemImage: "bed.double")
                    }
                    
                    // Botão de reset
                    Button(role: .destructive) {
                        AppUsageTracker.shared.resetUsageForTesting()
                    } label: {
                        Label("Resetar Tempo", systemImage: "arrow.counterclockwise")
                    }
                    
                    // Watch sync
                    Button {
                        syncWithWatchManually()
                    } label: {
                        HStack {
                            Label("⌚ Sincronizar com Watch", systemImage: "applewatch")
                            Spacer()
                            Text("\(viewModel.content.count) posts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Toggle do banner de Digest
                    Toggle(isOn: $debugShowDigestBanner) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🔥 Mostrar Banner de Digest")
                            Text("Simula fim de semana para testar o banner")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Beta Tester Debug
                    Button {
                        withAnimation {
                            BetaTesterService.shared.forceBetaTesterStatus(!BetaTesterService.shared.isBetaTester)
                        }
                    } label: {
                        Label(
                            BetaTesterService.shared.isBetaTester ? "⭐ Remover Badge Beta" : "⭐ Ativar Badge Beta",
                            systemImage: "star.circle"
                        )
                    }
                } header: {
                    Label("Debug", systemImage: "hammer.fill")
                } footer: {
                    Text("Ferramentas de desenvolvimento para testes. O banner de Digest normalmente só aparece nos fins de semana (sábado e domingo).")
                }
                #endif
                
                // Versão
                Section {
                    HStack {
                        Text("Versão")
                        Spacer()
                        Text("2.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.top, 50)
            .scrollContentBackground(.hidden)
            .navigationTitle("Ajustes")
            .background {
                ZStack {
                    Color("Background")
                        .ignoresSafeArea()
                    Image("ruido")
                        .resizable()
                        .scaledToFill()
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                }
            }
            .alert("Limpar Cache da API", isPresented: $showingClearCache) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpar", role: .destructive) {
                    clearAPICache()
                }
            } message: {
                Text("Isso irá remover respostas HTTP em cache, forçando o app a buscar posts atualizados.")
            }
            .alert("⚠️ Limpar Biblioteca Completa", isPresented: $showingClearLibrary) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpar TUDO", role: .destructive) {
                    clearCompleteLibrary()
                }
            } message: {
                Text("Isso irá remover PERMANENTEMENTE todos os seus dados: curtidas (\(viewModel.likedList.count)), destaques (\(highlights.count)), anotações (\(notes.count)) e pastas (\(folders.count)). Esta ação não pode ser desfeita!")
            }
            .sheet(isPresented: $showAuthSheet) {
                AuthSheet()
            }
            .alert("Sair da Conta", isPresented: $showLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Sair", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Tem certeza que deseja sair da sua conta?")
            }
        }
    }
    
    // MARK: - Views
    
    private var profileSection: some View {
        Group {
            if authService.isAuthenticated, let user = authService.currentUser {
                // Usuário logado - Design minimalista estilo Uber/BeReal
                VStack(spacing: 12) {
                    // Card do perfil (não clicável!)
                    VStack(spacing: 16) {
                        // Avatar e username
                        HStack(spacing: 12) {
                            // Avatar com badge Beta se aplicável
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(Color.primary.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Text(String(user.username.prefix(1).uppercased()))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    )
                                
                                // Badge Beta Tester
                                if BetaTesterService.shared.isBetaTester {
                                    Circle()
                                        .fill(Color.primary)
                                        .frame(width: 16, height: 16)
                                        .overlay(
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(Color("Background"))
                                        )
                                        .offset(x: 2, y: 2)
                                }
                            }
                            
                            // Username e badge
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text("@\(user.username)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    if BetaTesterService.shared.isBetaTester {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                }
                                
                                Text("TabNews")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Stats (TabCoins e TabCash) - horizontal compacto
                        HStack(spacing: 24) {
                            if let tabcoins = user.tabcoins {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("\(tabcoins)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("TabCoins")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            if let tabcash = user.tabcash {
                                HStack(spacing: 6) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("\(tabcash)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("TabCash")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .allowsHitTesting(false) // Desabilita toques no card do perfil
                    
                    // Botão de Logout separado - minimalista
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline)
                            Text("Sair")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .foregroundStyle(.red)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            } else {
                // Usuário não logado - Design minimalista estilo Uber/BeReal
                VStack(spacing: 12) {
                    // Card de login - super minimalista
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title3)
                                    .foregroundStyle(.primary)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Faça login")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Entre ou crie uma conta para comentar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Botões de ação - estilo Uber/BeReal
                    VStack(spacing: 8) {
                        Button {
                            showAuthSheet = true
                        } label: {
                            Text("Criar Conta")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.primary)
                                .foregroundStyle(Color("Background"))
                                .cornerRadius(8)
                        }
                        
                        Button {
                            showAuthSheet = true
                        } label: {
                            Text("Entrar")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .foregroundStyle(.primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    
    private var betaTesterBadgeCard: some View {
        HStack(spacing: 16) {
            // Ícone animado com gradiente
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            // Conteúdo
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Beta Tester")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.body)
                }
            }
            
            Spacer()
            
            // Sparkles decoration
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardColor"))
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.3), .pink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Functions
    private func clearAPICache() {
        // Limpar todas as respostas HTTP em cache (posts, newsletters, etc)
        URLCache.shared.removeAllCachedResponses()
        
        // Opcional: Limpar cookies de sessão (se houver)
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    }
    
    #if DEBUG
    private func syncWithWatchManually() {
        let recentPosts = Array(viewModel.content.prefix(5))
        let likedPosts = Array(viewModel.likedList.prefix(10))
        
        let stats = [
            "liked": viewModel.likedList.count,
            "highlights": highlights.count,
            "notes": notes.count,
            "folders": folders.count
        ]
        
        WatchSyncManager.shared.syncToWatch(
            posts: recentPosts,
            likedPosts: likedPosts,
            stats: stats
        )
    }
    #endif
    
    private func clearCompleteLibrary() {
        // 1. Limpar curtidas
        viewModel.clearAllLikedContent()
        
        // 2. Limpar todos os destaques
        for highlight in highlights {
            modelContext.delete(highlight)
        }
        
        // 3. Limpar todas as anotações
        for note in notes {
            modelContext.delete(note)
        }
        
        // 4. Limpar todas as pastas
        for folder in folders {
            modelContext.delete(folder)
        }
        
        // Salvar alterações
        try? modelContext.save()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var currentTheme: Theme = .light
    static var previews: some View {
        SettingsView(isViewInApp: .constant(true), currentTheme: .constant(currentTheme))
    }
}
