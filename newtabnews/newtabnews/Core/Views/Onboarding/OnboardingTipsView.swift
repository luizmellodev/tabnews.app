import SwiftUI

struct OnboardingTipsView: View {
    @Binding var showOnboarding: Bool
    @State private var currentTip = 0
    @Environment(\.colorScheme) var colorScheme
    var onNavigateToLibrary: (() -> Void)?
    
    private var overlayColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.9) : Color.black.opacity(0.7)
    }
    
    private let tips: [CoachMark] = [
        CoachMark(
            title: "Pressione e Segure",
            message: "Segure um post para ver atalhos rápidos: curtir, salvar em pasta ou ouvir",
            xOffset: 0,
            yOffset: 150,
            arrow: .down
        ),
        CoachMark(
            title: "Biblioteca",
            message: "Aqui você encontra seus posts curtidos, destaques, anotações e pastas organizadas",
            xOffset: -35,
            yOffset: 230,
            arrow: .up
        ),
        CoachMark(
            title: "Criar Pastas",
            message: "Toque no botão + para criar pastas personalizadas e organizar seus posts",
            xOffset: 0,
            yOffset: 145,
            arrow: .down
        ),
        CoachMark(
            title: "Atenção!",
            message: "Este app não é oficial do TabNews e não possui vínculo com Filipe Deschamps. É um projeto independente e open source criado pela comunidade para ser um complemento ao site oficial.",
            xOffset: 0,
            yOffset: 0,
            arrow: .none
        )
    ]
    
    var body: some View {
        ZStack {
            if currentTip == 1 {
                VStack(spacing: 0) {
                    overlayColor
                    Color.clear
                        .frame(height: 100)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    nextTip()
                }
            } else {
                overlayColor
                    .ignoresSafeArea()
                    .onTapGesture {
                        if currentTip != 0 {
                            nextTip()
                        }
                    }
            }
            
            // Context menu simulado para primeira dica
            if currentTip == 0 {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 280)
                    
                    VStack(spacing: 0) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "heart")
                                    .foregroundColor(.red)
                                Text("Curtir")
                                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                                Spacer()
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                        
                        Divider()
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                    .foregroundColor(.blue)
                                Text("Salvar em Pasta")
                                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                                Spacer()
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                        
                        Divider()
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "speaker.wave.2")
                                    .foregroundColor(.green)
                                Text("Ouvir Post")
                                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                                Spacer()
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }
                    }
                    .background(colorScheme == .dark ? Color("PrimaryColor") : Color.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 50)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Spacer()
                }
                .zIndex(1)
            }
            
            // Tooltip
            GeometryReader { geometry in
                if currentTip < tips.count {
                    CoachMarkView(
                        tip: tips[currentTip],
                        currentStep: currentTip + 1,
                        totalSteps: tips.count,
                        onNext: nextTip,
                        onSkip: completeOnboarding,
                        screenSize: geometry.size
                    )
                }
            }
            .zIndex(2)
        }
    }
    
    private func nextTip() {
        if currentTip < tips.count - 1 {
            withAnimation(.spring(response: 0.3)) {
                currentTip += 1
                
                if currentTip == 1 {
                    onNavigateToLibrary?()
                }
                
                if currentTip == 3 {
                    NotificationCenter.default.post(name: .navigateToHome, object: nil)
                }
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenTipsOnboarding")
        withAnimation {
            showOnboarding = false
        }
    }
}

struct CoachMarkView: View {
    let tip: CoachMark
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let onSkip: () -> Void
    let screenSize: CGSize
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if tip.arrow == .none {
            // Tela final centralizada
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text(tip.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(tip.message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30)
                
                Button {
                    onNext()
                } label: {
                    Text("Começar a usar")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color("PrimaryColor") : .white)
                    .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
            )
            .padding(.horizontal, 30)
            .position(x: screenSize.width / 2, y: screenSize.height / 2)
        } else {
            // Dicas contextuais
            VStack(spacing: 0) {
                if tip.arrow == .down {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.title)
                        .foregroundColor(colorScheme == .dark ? Color("PrimaryColor") : .white)
                        .padding(.bottom, -5)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(tip.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        Button("Pular") {
                            onSkip()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    Text(tip.message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<totalSteps, id: \.self) { index in
                                Circle()
                                    .fill(index < currentStep ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        Spacer()
                        Button {
                            onNext()
                        } label: {
                            Text(currentStep == totalSteps ? "Começar" : "Próximo")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme == .dark ? Color("PrimaryColor") : Color.white)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .frame(maxWidth: 300)
                
                if tip.arrow == .up {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.title)
                        .foregroundColor(colorScheme == .dark ? Color("PrimaryColor") : .white)
                        .padding(.top, -5)
                }
            }
            .position(
                x: screenSize.width / 2 + tip.xOffset,
                y: screenSize.height / 2 + tip.yOffset
            )
        }
    }
}

struct CoachMark {
    let title: String
    let message: String
    let xOffset: CGFloat
    let yOffset: CGFloat
    let arrow: Arrow
    
    enum Arrow {
        case none, up, down
    }
}
