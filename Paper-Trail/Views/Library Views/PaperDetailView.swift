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
    @State var store = LibraryStore.shared

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.secondary, lineWidth: 1.5)
            )
            .shadow(radius: 6)

        PaperCardContent(paper: paper, hasSeen: true)
            .padding()
    }
}
