//
//  ContentView.swift
//  RssSwiftUI
//
//  Created by Dmitry Kocherovets on 06.11.2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NewsListView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("News 1")
            }
            NewsListView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("News 2")
            }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
