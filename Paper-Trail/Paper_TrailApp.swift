//
//  Paper_TrailApp.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 11/15/25.
//

import SwiftUI

@main
struct Paper_TrailApp: App {
    var body: some Scene {
        WindowGroup {
            AdvancedSearchView()
                .environment(PaperTrailViewModel())
        }
    }
}
