//
//  NewsletterView.swift
//  newtabnews
//
//  Created by Luiz Mello on 02/08/23.
//

import SwiftUI
import Foundation

struct NewsletterView: View {
    
    @EnvironmentObject var viewModel: NewsletterViewModel
    @Binding var isViewInApp: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                Image("ruido")
                    .resizable()
                    .scaledToFill()
                    .blendMode(.overlay)
                    .ignoresSafeArea()
                
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .scaleEffect(1.5)
                    
                case .requestSucceeded:
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            headerView
                            
                            if let latestNewsletter = viewModel.newsletter.first {
                                Button(action: {
                                    NotificationManager.shared.scheduleTestNotification(for: latestNewsletter)
                                }) {
                                    Text("Testar Notificação (10s)")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.bottom)
                            }
                            
                            ForEach(viewModel.newsletter) { newsletter in
                                NewsletterCard(newsletter: newsletter, isNew: isCreatedToday(createdAt: newsletter.createdAt))
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 60)
                    
                case .requestFailed:
                    FailureView(currentTheme: .constant(.dark))
                    
                default:
                    Color.clear
                }
            }
            .task {
                if !viewModel.alreadyLoaded {
                    await viewModel.fetchNewsletterContent()
                    await viewModel.fetchNewsletterPost()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Newsletter")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Fique por dentro das novidades")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .padding(.vertical)
    }
    
    private func isCreatedToday(createdAt: String?) -> Bool {
        guard let createdAtString = createdAt else {
            return false
        }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let createdDate = dateFormatter.date(from: createdAtString) else {
            return false
        }
        
        let calendar = Calendar.current
        let createdComponents = calendar.dateComponents([.day, .month], from: createdDate)
        let currentComponents = calendar.dateComponents([.day, .month], from: Date())
        
        return createdComponents.day == currentComponents.day &&
               createdComponents.month == currentComponents.month
    }
}
