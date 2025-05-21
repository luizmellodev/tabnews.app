//
//  NewsletterViewModel.swift
//  newtabnews
//
//  Created by Luiz Mello on 11/03/25.
//

import Foundation
import SwiftUI

@Observable
class NewsletterViewModel: ObservableObject {
    private let service: ContentServiceProtocol
    var newsletter: [PostRequest] = []
    var state: DefaultViewState = .started
    var alreadyLoaded: Bool = false
    
    init(service: ContentServiceProtocol = ContentService()) {
        self.service = service
    }
    
    @MainActor
    func fetchNewsletterContent() async {
        self.state = .loading
        do {
            self.newsletter = try await service.getNewsletter(page: "1", perPage: "15", strategy: "new")
            
            if let latestNewsletter = self.newsletter.first {
                NotificationManager.shared.scheduleDailyNewsletterNotification(for: latestNewsletter)
            }
            
            self.state = .requestSucceeded
            self.alreadyLoaded = true
        } catch {
            self.state = .requestFailed
            print(error)
        }
    }
    
    @MainActor
    func fetchNewsletterPost() async {
        for index in newsletter.indices {
            do {
                let response = try await service.getPost(
                    user: newsletter[index].ownerUsername ?? "erro",
                    slug: newsletter[index].slug ?? "erro"
                )
                newsletter[index].body = response.body
            } catch {
                self.state = .requestFailed
                print("Deu algum erro!! \(error)")
            }
        }
    }
}
