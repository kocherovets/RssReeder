//
//  NewsListView.swift
//  RssSwiftUI
//
//  Created by Dmitry Kocherovets on 06.11.2020.
//

import SwiftUI

struct NewsListView: View {
    var body: some View {
        NavigationView {
            Text ("News")
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: { print("Edit button was tapped") },
                                    label: { Image(systemName: "star") }),
                    trailing: Button(action: { print("Edit button was tapped") },
                                     label: { Image(systemName: "eye") }))
        }
    }
}

struct NewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NewsListView()
    }
}
