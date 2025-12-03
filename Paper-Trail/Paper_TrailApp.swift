//
//  Paper_TrailApp.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 11/15/25.
//

import SwiftUI
import SwiftData

@main
struct Paper_TrailApp: App {
    @State var vm = PaperTrailViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(vm)
        }
    }
}
