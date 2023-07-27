//
//  WebContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import SwiftUI

struct WebContentView: View {
    @State var bodyContent = ""
    var content: ContentRequest
    
    var body: some View {
        VStack {
            HTMLView(request: URLRequest(url: URL(string: "https://www.tabnews.com.br/\(content.ownerUsername ?? "")/\(content.slug ?? "")")!)
            )
        }
    }
}

struct WebContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebContentView(content: ContentRequest(id: nil, ownerID: nil, parentID: nil, slug: nil, title: nil, status: nil, sourceURL: nil, createdAt: nil, updatedAt: nil, publishedAt: nil, deletedAt: nil, ownerUsername: nil, tabcoins: nil, childrenDeepCount: nil))
    }
}
