import SwiftUI
struct EmptyLikedListView: View {
@ObservedObject var gameController: GameController
@State private var isAnimating = false

var body: some View {
    VStack(spacing: 24) {
        Spacer()
        
        // Ícone animado
        Image(systemName: "heart.slash")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80)
            .foregroundStyle(.gray)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
        
        VStack(spacing: 16) {
            Text("Nenhum favorito ainda")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            
            Text("Encontre conteúdos interessantes e salve-os aqui para ler depois")
                .font(.body)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
        }
        
        // Botão do jogo com efeito hover
        NavigationLink {
            Game(controller: gameController)
                .onAppear {
                    gameController.activate()
                }
        } label: {
            HStack {
                Image(systemName: "gamecontroller.fill")
                Text("Jogar enquanto isso")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
                    .shadow(radius: 5)
            )
            .scaleEffect(isAnimating ? 1.05 : 1)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: isAnimating
            )
        }
        
        Spacer()
    }
    .padding()
    .onAppear {
        withAnimation {
            isAnimating = true
        }
    }
}
}