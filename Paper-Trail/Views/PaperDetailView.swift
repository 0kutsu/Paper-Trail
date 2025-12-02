//
//  PaperDetailView.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 12/1/25.
//

import SwiftUI
import Foundation

struct PaperDetailView: View {
    let paper: Paper
    @Bindable var store = LibraryStore.shared

    var body: some View {
        PaperCardContent(
            paper: paper,
            hasSeen: store.hasSeen(paper)
        )
        .navigationTitle(paper.title ?? "Paper")
//        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.markSeen(paper)
        }
    }
}
