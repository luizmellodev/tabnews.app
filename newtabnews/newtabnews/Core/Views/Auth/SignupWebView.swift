//
//  SignupWebView.swift
//  newtabnews
//
//  Created by Luiz Mello on 07/01/26.
//

import SwiftUI
import SafariServices

struct SignupWebView: UIViewControllerRepresentable {
    let url = URL(string: "https://www.tabnews.com.br/cadastro")!
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.dismissButtonStyle = .done
        safari.preferredControlTintColor = .label
        safari.preferredBarTintColor = .systemBackground
        
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nada a atualizar
    }
}

#Preview {
    SignupWebView()
}
