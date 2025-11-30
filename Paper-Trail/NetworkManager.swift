//
//  NetworkManager.swift
//  Paper-Trail
//
//  Created by Angelina Cheng on 11/26/25.
//

import Foundation
import SwiftData

enum NetworkError: String, Error {
    case networkError
    case invalidURL
    case decodingError
    case tooManyRequests
}

class NetworkManager {
    static let instance = NetworkManager()
    
    let baseURL = "https://api.semanticscholar.org/graph/v1/paper/search?query="
    
    private let fields =
        "paperId,title,abstract,openAccessPdf,fieldsOfStudy,publicationDate,authors,tldr,externalIds,publicationTypes"
    
    private let resultLimit = 50
    
    func getAdvancedSearch(tags: [String],
                           authors: [String],
                           citationCount: Int?,
                           startDate: String,
                           endDate: String,
                           onlyOpenAccess: Bool) async throws -> ReturnedData {
        let tagsArray: [String] = {
            var array: [String] = []
            for tag in tags {
                let splitTag = tag.components(separatedBy: " ")
                array.append(contentsOf: splitTag)
            }
            return array
        }()
        let tagsQuery = tagsArray.joined(separator: "+")
        let authorArray: [String] = {
            var array: [String] = []
            for author in authors {
                let splitAuthor = author.components(separatedBy: " ")
                array.append(contentsOf: splitAuthor)
            }
            return array
        }()
        let authorsQuery = authorArray.joined(separator: "+")
        
        let query = "\(tagsQuery)+\(authorsQuery)"
        
        var hasCitationCount = false
        var citationQuery = ""
        if let minCitationCount = citationCount {
            citationQuery = String(minCitationCount)
            hasCitationCount = true
        } else {
            hasCitationCount = false
        }
        
        guard let url = URL(string: hasCitationCount ?
                            (onlyOpenAccess ?
                             "\(baseURL)\(query)&year=\(startDate):\(endDate)&openAccessPdf&fields=\(fields)&minCitationCount=\(citationQuery)&limit=\(resultLimit)"
                             :
                             "\(baseURL)\(query)&year=\(startDate):\(endDate)&fields=\(fields)&minCitationCount=\(citationQuery)&limit=\(resultLimit)")
                            :
                            (onlyOpenAccess ?
                             "\(baseURL)\(query)&year=\(startDate):\(endDate)&openAccessPdf&fields=\(fields)&limit=\(resultLimit)"
                             :
                             "\(baseURL)\(query)&year=\(startDate):\(endDate)&fields=\(fields)&limit=\(resultLimit)")
        ) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            print("cast correctly")
            if httpResponse.statusCode == 429 {
                throw NetworkError.tooManyRequests
            }
        } else {
            print("cast incorrectly")
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode >= 200,
              httpResponse.statusCode <= 299 else {
            print("Network error")
            throw NetworkError.networkError
        }
        
        let decoder = JSONDecoder()
        
        let _ = String(data: data, encoding: .utf8)
        do {
            let _ = try decoder.decode(ReturnedData.self, from: data)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
        return try decoder.decode(ReturnedData.self, from: data)
    }
    
    func getCasualSearch(tags: [String]) async throws -> ReturnedData {
        
        let tagsArray: [String] = {
            var array: [String] = []
            for tag in tags {
                let splitTag = tag.components(separatedBy: " ")
                array.append(contentsOf: splitTag)
            }
            return array
        }()
        let tagsQuery = tagsArray.joined(separator: "+")
        
        var fieldOfStudyTags: [String] = []
        let containsFieldOfStudy: Bool = { () -> Bool in
            var contains = false
            for tag in tags {
                if suggestedTags.contains(tag) {
                    fieldOfStudyTags.append(tag)
                    contains = true
                }
            }
            return contains
        }()
        
        
        guard let url = URL(string: containsFieldOfStudy
                            ? "\(baseURL)\(tagsQuery)&fieldsOfStudy=\(fieldOfStudyTags.joined(separator: ","))&fields=\(fields)&limit=\(resultLimit)"
                            : "\(baseURL)\(tagsQuery)&fields=\(fields)&limit=\(resultLimit)"
        ) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            print("cast correctly")
            if httpResponse.statusCode == 429 {
                throw NetworkError.tooManyRequests
            }
        } else {
            print("cast incorrectly")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode >= 200,
              httpResponse.statusCode <= 299 else {
            print("Network error")
            throw NetworkError.networkError
        }
        
        let decoder = JSONDecoder()
        
        let _ = String(data: data, encoding: .utf8)
        do {
            let _ = try decoder.decode(ReturnedData.self, from: data)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
        return try decoder.decode(ReturnedData.self, from: data)
    }
}
