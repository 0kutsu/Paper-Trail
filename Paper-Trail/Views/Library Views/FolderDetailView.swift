//
//  FolderView.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 11/29/25.
//

import SwiftUI

struct FolderDetailView: View {
    let folder: PaperFolder
    @State var store = LibraryStore.shared
    
    var papers: [Paper] {
        folder.paperIDs.compactMap { id in
            store.loadPaper(with: id)
        }
    }
    
    var body: some View {
        List(papers, id: \.stableID) { paper in
            NavigationLink {
                PaperDetailView(paper: paper)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(paper.title ?? "Untitled paper")
                        .font(.headline)
                    
                    if let authors = paper.authorNames.first {
                        Text(authors)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let date = paper.publicationDateFormatted {
                        Text(date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(folder.name)
    }
}
