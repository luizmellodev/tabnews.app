import SwiftUI

private struct PostRow: View {
    let post: PostRequest
    @Binding var isViewInApp: Bool
    let viewModel: MainViewModel
    @Binding var currentTheme: Theme

    
    var body: some View {
        NavigationLink {
            if isViewInApp {
                ListDetailView(
                    isViewInApp: $isViewInApp,
                    post: post,
                    currentTheme: $currentTheme,
                    viewModel: viewModel
                )
            } else {
                WebContentView(content: post)
            }
        } label: {
            CardList(post: post)
        }
        .contextMenu {
            Button {
                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                impactHeavy.impactOccurred()
                viewModel.likeContentList(content: post)
            } label: {
                Text("Curtir")
            }
        }
        .padding(.top, 20)
    }
}