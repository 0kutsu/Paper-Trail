//
//  CollectionPickerView.swift
//  PaperTrailFinal
//
//  Created by Arina Velieva on 11/27/25.
//


import SwiftUI

struct CollectionPickerView: View {
    let paper: Paper
    @State var library: LibraryStore
    @Environment(\.dismiss) private var dismiss

    @State private var newFolderName: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Quick actions") {
                    Button {
                        library.addToFavorites(paper)
                        dismiss()
                    } label: {
                        Label("Save to Favorites", systemImage: "star.fill")
                    }
                }

                
                if !library.folders.isEmpty {
                    Section("Existing folders") {
                        ForEach(library.folders) { folder in
                            Button {
                                library.add(paper, to: folder)
                                dismiss()
                            } label: {
                                Label(folder.name, systemImage: "folder")
                            }
                        }
                    }
                }

                
                Section("Create new folder") {
                    HStack {
                        TextField("Folder name", text: $newFolderName)
                            .textInputAutocapitalization(.words)
                        Button("Add") {
                            let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }

                            library.addFolder(named: trimmed)
                            if let folder = library.folders.first(where: { $0.name == trimmed }) {
                                library.add(paper, to: folder)
                            }
                            newFolderName = ""
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}


#Preview {
    let samplePaper = Paper(
        paperId: "12345",
        title: "Sample Paper",
        abstract: "Sample abstract for preview.",
        openAccessPdf: Pdf(url: "https://example.com/sample.pdf"),
        fieldsOfStudy: ["Computer Science"],
        publicationDate: "2024-01-01",
        authors: [Author(authorId: "1", name: "Jane Doe")],
        tldr: Tldr(text: "Preview TL;DR"),
        externalIds: ExternalIds(DOI: "10.1111/example.doi",
                                 PubMed: nil,
                                 ArXiv: nil),
        publicationTypes: ["JournalArticle"]
    )

    CollectionPickerView(
        paper: samplePaper,
        library: LibraryStore.shared
    )
}
