//
//  SettingsView.swift
//  tabnewsios
//
//  Created by Luiz Eduardo Mello dos Reis on 31/12/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    @State var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configurações")) {
                    Toggle("Visualizar conteúdo no App:", isOn: $isViewInApp)
                    Toggle("Dark Mode:", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { _ in
                            currentTheme = isDarkMode ? .dark : .light
                        }
                }
                Section(header: Text("Sobre esse projeto")) {
                    HStack {
                        Text("Esse projeto não é oficial do TabNews. Criei com o intuito de poder receber doses diárias de conteúdo sem precisar abrir o TabNews, ou seja, através de notificações. A ideia é todos os dias você receber uma notificação sobre um conteúdo postado no TabNews!")
                    }
                    VStack(alignment: .leading) {
                        Group {
                            Text("Futuros updates:")
                            Text("- Sincronia com Apple Watch\n")
                            Text("- Envio de notificações diárias\n")
                            Text("- Configuração de visualizão de conteúdo (recentes ou relevantes)\n")
                            Text("- Otimização de requisição da API (desculpa por tudo, Deschamps :p\n")
                        }
                        .foregroundColor(.gray)
                    }
                }
                Section(header: Text("Sobre os criadores")) {
                    NavigationLink(destination: SocialView(github: "filipedeschamps", linkedin: "filipedeschamps", youtube: "FilipeDeschamps", instagram: "filipedeschamps")) {
                        Text("Felipe Deschamps - Criador do Tab News")
                        
                    }
                    NavigationLink {
                        SocialView(github: "luizmellodev", linkedin: "luizmellodev", youtube: "", instagram: "luizmello.dev")
                    } label: {
                        Text("Luiz Mello  - Criador desse aplicativo não oficial")
                    }
                }
                .navigationBarTitle(Text("Configurações"))
                .onAppear {
                    self.isDarkMode = currentTheme == .dark ? true : false
                    self.isViewInApp = viewModel.defaults.bool(forKey: "viewInApp")
                }
            }
        }
    }
}
struct SocialView: View {
    var github, linkedin, youtube, instagram: String
    var body: some View {
        List {
            HStack {
                Button {
                    openInstagram(username: instagram)
                } label: {
                    Text("Instagram")
                }
            }
            
            HStack {
                Button {
                    openGithub(username: github)
                } label: {
                    Text("GitHub")
                }
            }
            HStack {
                Button {
                    openLinkedin(username: linkedin)
                } label: {
                    Text("LinkedIn")
                }
            }
            if youtube != "" {
                HStack {
                    Button {
                        openYouTube(username: youtube)
                    } label: {
                        Text("Youtube")
                    }
                }
            } else {
                NavigationLink {
                    DuckView()
                } label: {
                    Text("Duck")
                        .foregroundColor(.blue)
                }

            }
        }
        .navigationTitle(Text("Redes Sociais"))
    }
    func openWebURL(weburl: URL) {
        //redirect to safari because the user doesn't have Instagram
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(weburl, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(weburl)
        }
    }
    func openInstagram(username: String) {
        let appURL = URL(string:  "instagram://user?username=\(username)")!
        let webURL = URL(string:  "https://instagram.com/\(username)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else { openWebURL(weburl: webURL) }
    }
    
    func openGithub(username: String) {
        let appURL = URL(string:  "github://\(username)")!
        let webURL = URL(string:  "https://github.com/\(username)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else { openWebURL(weburl: webURL) }
    }
    
    func openYouTube(username: String) {
        let appURL = URL(string:  "youtube://@\(username)")!
        let webURL = URL(string:  "https://youtube.com/@\(username)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else { openWebURL(weburl: webURL) }
    }
    
    func openLinkedin(username: String) {
        let appURL = URL(string:  "linedin://\(username)")!
        let webURL = URL(string:  "https://www.linkedin.com/in/\(username)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else { openWebURL(weburl: webURL) }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var viewModel = MainViewModel()
    static var currentTheme: Theme = .light
    static var previews: some View {
        SettingsView(viewModel: viewModel, isViewInApp: .constant(true), currentTheme: .constant(currentTheme))
    }
}
