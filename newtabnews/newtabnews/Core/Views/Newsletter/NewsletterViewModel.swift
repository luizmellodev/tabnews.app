import SwiftUI

@MainActor
class NewsletterViewModel: ObservableObject {
    @Published var newsletter: [Post] = []
    @Published var state: FetchState = .idle
    
    let service = ApiService()
    
    // Get newsletter titles
    func fetchNewsletterContent() async {
        self.state = .loading
        let contentResponse = await service.getNewsletter(page: "1", perPage: "30", strategy: "new")
        
        switch contentResponse {
        case .success(let response):
            self.state = .requestSucceeded
            self.newsletter = response
            
        case .failure(let error), .customError(let error):
            self.state = .requestFailed
            print(error)
        }
    }
    
    // Get newsletter post (content)
    func fetchNewsletterPost(for postIndex: Int, slug: String) async {
        let postContentResponse = await service.getPost(user: "NewsletterOficial", slug: slug)
        
        switch postContentResponse {
        case .success(let content):
            DispatchQueue.main.async {
                self.newsletter[postIndex].content = content // Adiciona o conteúdo ao post
            }
        case .failure(let error), .customError(let error):
            print("Erro ao buscar conteúdo do post \(slug): \(error)")
        }
    }
}
