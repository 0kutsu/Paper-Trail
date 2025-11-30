//
//  Paper.swift
//  Paper-Trail
//
//  Created by Angelina Cheng on 11/26/25.
//

import Foundation
import SwiftData

struct ReturnedData: Decodable, Hashable {
    let total: Int
    let data: [Paper]?
    
    enum CodingKeys: String, CodingKey {
        case total
        case data
    }
}

struct ExternalIds: Decodable, Hashable {
    let DOI: String?
    let PubMed: String?
    let ArXiv: String?
}

struct Paper: Decodable, Hashable {
    let paperId: String?
    let title: String?
    let abstract: String?
    let openAccessPdf: Pdf
    let fieldsOfStudy: [String]?
    let publicationDate: String?
    let authors: [Author]?
    let tldr: Tldr?
    let externalIds: ExternalIds?
    let publicationTypes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case paperId
        case title
        case abstract
        case openAccessPdf
        case fieldsOfStudy
        case publicationDate
        case authors
        case tldr
        case externalIds
        case publicationTypes
    }
}

struct Pdf: Decodable, Hashable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url
    }
}

struct Author: Decodable, Hashable {
    let authorId: String?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case authorId
        case name
    }
}

struct Tldr: Decodable, Hashable {
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case text
    }
}
