import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Bem-vindo ao TabNews",
            subtitle: "O app não oficial da sua plataforma favorita de conteúdo",
            imageName: "doc.text.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Notificações Locais",
            subtitle: "Receba notificações da newsletter diretamente no seu dispositivo",
            imageName: "bell.badge.fill",
            color: .purple
        ),
        OnboardingPage(
            title: "Como Ler",
            subtitle: "Escolha entre ler direto no app ou no site do TabNews. Recomendamos o site para uma experiência completa do markdown",
            imageName: "text.book.closed.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Em Evolução",
            subtitle: "Novas atualizações chegando em breve com mais funcionalidades!",
            imageName: "sparkles.rectangle.stack.fill",
            color: .green
        )
    ]
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index], isLast: index == pages.count - 1) {
                        withAnimation {
                            showOnboarding = false
                            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLast: Bool
    let completion: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(page.color)
                .symbolRenderingMode(.hierarchical)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.5)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .bold()
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            
            Spacer()
            
            if isLast {
                Button {
                    completion()
                } label: {
                    Text("Começar")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(page.color.gradient)
                        }
                        .padding(.horizontal, 32)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            
            Spacer()
                .frame(height: 60)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(duration: 0.7)) {
                showContent = true
            }
        }
        .onDisappear {
            showContent = false
        }
    }
}