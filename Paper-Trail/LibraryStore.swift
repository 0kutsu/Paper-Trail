//
//  LibraryStore.swift
//  PaperTrailFinal
//
//  Created by Arina Velieva on 11/27/25.
//


import Foundation
import SwiftUI


struct PaperFolder: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var paperIDs: [String]

    init(id: UUID = UUID(), name: String, paperIDs: [String] = []) {
        self.id = id
        self.name = name
        self.paperIDs = paperIDs
    }
}


@Observable
final class LibraryStore {
    static let shared = LibraryStore()

    private(set) var favoriteIDs: Set<String> = []
    private(set) var seenPaperIDs: Set<String> = []
    private(set) var folders: [PaperFolder] = []

    private let favoritesKey = "papertrail_favorite_ids"
    private let seenKey      = "papertrail_seen_ids"
    private let foldersKey   = "papertrail_folders"

    private init() {
        load()
    }


    func isFavorite(_ paper: Paper) -> Bool {
        favoriteIDs.contains(paper.stableID)
    }

    func addToFavorites(_ paper: Paper) {
        favoriteIDs.insert(paper.stableID)
        markSeen(paper)
        save()
    }

    func removeFromFavorites(_ paper: Paper) {
        favoriteIDs.remove(paper.stableID)
        save()
    }


    func hasSeen(_ paper: Paper) -> Bool {
        seenPaperIDs.contains(paper.stableID)
    }

    func markSeen(_ paper: Paper) {
        if !hasSeen(paper) {
            seenPaperIDs.insert(paper.stableID)
            save()
        }
    }


    func addFolder(named name: String) {
        guard !folders.contains(where: { $0.name == name }) else { return }
        folders.append(PaperFolder(name: name))
        save()
    }

    func add(_ paper: Paper, to folder: PaperFolder) {
        guard let idx = folders.firstIndex(where: { $0.id == folder.id }) else { return }

        let pid = paper.stableID
        if !folders[idx].paperIDs.contains(pid) {
            folders[idx].paperIDs.append(pid)
        }

        favoriteIDs.insert(pid)
        markSeen(paper)
        save()
    }


    private func load() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()

        if let favArray = defaults.array(forKey: favoritesKey) as? [String] {
            favoriteIDs = Set(favArray)
        }

        if let seenArray = defaults.array(forKey: seenKey) as? [String] {
            seenPaperIDs = Set(seenArray)
        }

        if let folderData = defaults.data(forKey: foldersKey),
           let decodedFolders = try? decoder.decode([PaperFolder].self, from: folderData) {
            folders = decodedFolders
        }
    }

    private func save() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        defaults.set(Array(favoriteIDs), forKey: favoritesKey)
        defaults.set(Array(seenPaperIDs), forKey: seenKey)

        if let data = try? encoder.encode(folders) {
            defaults.set(data, forKey: foldersKey)
        }
    }
}
