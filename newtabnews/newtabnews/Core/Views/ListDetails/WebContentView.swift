//
//  WebContentView.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import SwiftUI
import WebKit

struct WebContentView: View {
    @State var bodyContent = ""
    var content: PostRequest
    
    var body: some View {
        VStack {
            HTMLView(request: URLRequest(url: URL(string: "https://www.tabnews.com.br/\(content.ownerUsername ?? "")/\(content.slug ?? "")")!)
            )
        }
    }
}

struct WebContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebContentView(bodyContent: "", content: PostRequest(id: nil, ownerId: nil, parentId: nil, slug: nil, title: nil, body: nil, status: nil, type: nil, sourceUrl: nil, createdAt: nil, updatedAt: nil, publishedAt: nil, deletedAt: nil, ownerUsername: nil, tabcoins: nil, tabcoinsCredit: nil, tabcoinsDebit: nil, childrenDeepCount: nil))
    }
}
