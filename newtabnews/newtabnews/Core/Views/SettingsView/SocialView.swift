//
//  SocialView.swift
//  newtabnews
//
//  Created by Luiz Mello on 31/03/25.
//


import SwiftUI

struct SocialView: View {
    var github, linkedin, youtube, instagram: String
    var website: String? = nil
    
    var body: some View {
        List {
            if let website = website {
                HStack {
                    Button {
                        openWebsite(url: website)
                    } label: {
                        HStack {
                            Text("Site")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
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
    
    func openWebsite(url: String) {
        if let webURL = URL(string: url) {
            openWebURL(weburl: webURL)
        }
    }
}
