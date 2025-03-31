//
//  SettingsView.swift
//  tabnewsios
//
//  Created by Luiz Eduardo Mello dos Reis on 31/12/22.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var viewModel: MainViewModel
    @State var isDarkMode: Bool = false
    
    @Binding var isViewInApp: Bool
    @Binding var currentTheme: Theme
    
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

struct SettingsView_Previews: PreviewProvider {
    static var currentTheme: Theme = .light
    static var previews: some View {
        SettingsView(isViewInApp: .constant(true), currentTheme: .constant(currentTheme))
    }
}
