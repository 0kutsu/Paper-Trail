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

struct Paper: Decodable, Hashable {
    let paperId: String?
    let title: String?
    let abstract: String?
    let openAccessPdf: Pdf
    let fieldsOfStudy: [String]?
    let publicationDate: String?
    let authors: [Author]?
    
    enum CodingKeys: String, CodingKey {
        case paperId
        case title
        case abstract
        case openAccessPdf
        case fieldsOfStudy
        case publicationDate
        case authors
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
