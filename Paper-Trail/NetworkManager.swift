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
    
    func getAdvancedSearch(tags: [String], authors: [String], citationCount: Int?, startDate: String, endDate: String, onlyOpenAccess: Bool) async throws -> ReturnedData {
        // put tags into proper format
        let tagsArray: [String] = {
            var array: [String] = []
            for tag in tags {
                let splitTag = tag.components(separatedBy: " ")
                array.append(contentsOf: splitTag)
            }
            return array
        }()
        let tagsQuery = tagsArray.joined(separator: "+")
        
        // put authors into proper format
        let authorArray: [String] = {
            var array: [String] = []
            for author in authors {
                let splitAuthor = author.components(separatedBy: " ")
                array.append(contentsOf: splitAuthor)
            }
            return array
        }()
        let authorsQuery = authorArray.joined(separator: "+")
        
        // combine tags and authors into one search query
        let query = "\(tagsQuery)+\(authorsQuery)"
        
        // determine if user input a minumimum citation count
        var hasCitationCount = false
        var citationQuery = ""
        if let minCitationCount = citationCount {
            citationQuery = String(minCitationCount)
            hasCitationCount = true
        } else {
            hasCitationCount = false
        }
        
        // create url based on whether user used minimum citation count and/or open access
        guard let url = URL(string: hasCitationCount ?
                            onlyOpenAccess ?
                            "\(baseURL)\(query)&year=\(startDate):\(endDate)&openAccessPdf&fields=paperId,title,abstract,openAccessPdf,fieldsOfStudy,publicationDate,authors&minCitationCount=\(citationQuery)&limit=100" :
                            "\(baseURL)\(query)&year=\(startDate):\(endDate)&fields=paperId,title,abstract,openAccessPdf,fieldsOfStudy,publicationDate,authors&minCitationCount=\(citationQuery)&limit=100"
                            :
                                onlyOpenAccess ?
                                "\(baseURL)\(query)&year=\(startDate):\(endDate)&openAccessPdf&fields=paperId,title,abstract,openAccessPdf,fieldsOfStudy,publicationDate,authors&limit=100" :
                                "\(baseURL)\(query)&year=\(startDate):\(endDate)&fields=paperId,title,abstract,openAccessPdf,fieldsOfStudy,publicationDate,authors&limit=100"
        ) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // debugging for http response status code
        // often times status code is 429 -- too many requests sent
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            print("cast correctly")
            if httpResponse.statusCode == 429 {
                throw NetworkError.tooManyRequests
            }
        } else {
            print("cast incorrectly")
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            print("Network error")
            throw NetworkError.networkError
        }
        
        let decoder = JSONDecoder()
        
        // debugging for JSON decoder
        let dataStr = String(data: data, encoding: .utf8)
        do {
            let paperData = try decoder.decode(ReturnedData.self, from: data)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
        return try decoder.decode(ReturnedData.self, from: data)
    }
    
    func getCasualSearch(tags: [String]) async throws -> ReturnedData {
        // format user selected tags for url request
        let tagsArray: [String] = {
            var array: [String] = []
            for tag in tags {
                let splitTag = tag.components(separatedBy: " ")
                array.append(contentsOf: splitTag)
            }
            return array
        }()
        let tagsQuery = tagsArray.joined(separator: "+")
        
        // check if user selected one of the suggested tags
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
        
        // create different urls based on whether or not user selected one of the suggested tags
        guard let url = URL(string: containsFieldOfStudy ? "\(baseURL)\(tagsQuery)&fieldsOfStudy=\(fieldOfStudyTags.joined(separator: ","))&fields=paperId,title,abstract,openAccessPdf,fieldsOfStudy,publicationDate,authors&limit=100" : "\(baseURL)\(tagsQuery)&fields=paperId,title,abstract,openAccessPdf,fieldsOfStudy,publicationDate,authors&limit=100") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // debugging for http response status code
        // often times status code is 429 -- too many requests sent
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            print("cast correctly")
            if httpResponse.statusCode == 429 {
                throw NetworkError.tooManyRequests
            }
        } else {
            print("cast incorrectly")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
            print("Network error")
            throw NetworkError.networkError
        }
        
        let decoder = JSONDecoder()
        
        // debugging for JSON decoder
        let dataStr = String(data: data, encoding: .utf8)
        do {
            let paperData = try decoder.decode(ReturnedData.self, from: data)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        
        return try decoder.decode(ReturnedData.self, from: data)
    }
}
