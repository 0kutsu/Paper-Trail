//
//  RootView.swift
//  PaperTrailFinal
//
//  Created by Arina Velieva on 11/27/25.
//

import SwiftUI

struct RootView: View {
    @State private var vm = PaperTrailViewModel()

    var body: some View {
        NavigationStack {
            CasualSearchView()
        }
        .environment(vm)
    }
}

#Preview {
    RootView()
}
