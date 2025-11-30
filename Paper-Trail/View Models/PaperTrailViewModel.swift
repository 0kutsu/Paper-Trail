//
//  PaperTrailViewModel.swift
//  Paper-Trail
//
//  Created by Angelina Cheng on 11/26/25.
//

import Foundation

@Observable class PaperTrailViewModel {
    var tags: Set<String> = []
    var authors: Set<String> = []
    var papers: [Paper] = []
    
    func formatDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getAdvancedSearch(tags: [String],
                           authors: [String],
                           citationCount: String,
                           startDate: Date,
                           endDate: Date,
                           onlyOpenAccess: Bool) async throws -> [Paper]? {
        let startDateString = formatDateToString(date: startDate)
        let endDateString = formatDateToString(date: endDate)
        var citationCountInt: Int? = nil
        if citationCount != "" {
            citationCountInt = Int(citationCount)
        }
        
        do {
            let returnedData = try await NetworkManager.instance.getAdvancedSearch(
                tags: tags,
                authors: authors,
                citationCount: citationCountInt,
                startDate: startDateString,
                endDate: endDateString,
                onlyOpenAccess: onlyOpenAccess
            )
            return returnedData.data
        } catch NetworkError.tooManyRequests {
            return nil
        }
    }
    
    func getCasualSearch(input: Set<String>) async throws -> [Paper]? {
        do {
            let returnedData = try await NetworkManager.instance.getCasualSearch(tags: Array(input))
            return returnedData.data
        } catch NetworkError.tooManyRequests {
            return nil
        }
    }
    
    func addTag(_ tag: String) {
        tags.insert(tag)
    }
    
    func removeTag(_ tag: String) {
        tags.remove(tag)
    }
    
    func addAuthor(_ author: String) {
        authors.insert(author)
    }
    
    func removeAuthor(_ author: String) {
        authors.remove(author)
    }
}
