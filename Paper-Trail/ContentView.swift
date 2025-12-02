//
//  ContentView.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 11/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            CasualSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(PaperTrailViewModel())
}
