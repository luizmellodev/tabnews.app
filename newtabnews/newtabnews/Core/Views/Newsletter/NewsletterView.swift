//
//  NewsletterView.swift
//  newtabnews
//
//  Created by Luiz Mello on 02/08/23.
//

import SwiftUI

struct NewsletterView: View {
    
    @Binding var isViewInApp: Bool
    
    var viewModel: MainViewModel
    var newsletters: [ContentRequest]
    
    var body: some View {
        List {
            ForEach(newsletters) { newsletter in
                Text(newsletter.title ?? "erro no titulo kk")
            }
        }
    }
}
