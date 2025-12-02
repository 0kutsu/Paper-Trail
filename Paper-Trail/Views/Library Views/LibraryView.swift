//
//  LibraryView.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 11/29/25.
//

import SwiftUI

struct LibraryView: View {
    @State private var newFolderName: String = ""
    
    @State private var store = LibraryStore.shared

    var body: some View {
        NavigationStack {
            List {
                Section("Folders") {
                    ForEach(store.folders) { folder in
                        NavigationLink(value: folder) {
                            HStack {
                                Text(folder.name)
                                Spacer()
                                Text("\(folder.paperIDs.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section("Add Folder") {
                    HStack {
                        TextField("Folder name", text: $newFolderName)
                        Button("Add") {
                            if !newFolderName.trimmingCharacters(in: .whitespaces).isEmpty {
                                store.addFolder(named: newFolderName.trimmingCharacters(in: .whitespaces))
                                newFolderName = ""
                            }
                        }
                        .disabled(newFolderName.isEmpty)
                    }
                }
            }
            .navigationDestination(for: PaperFolder.self) { folder in
                FolderDetailView(folder: folder)
            }
            .navigationTitle("Library")
        }
    }
}

#Preview {
    LibraryView()
}
