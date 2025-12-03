//
//  PaperSaveable.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 12/2/25.
//

import Foundation

struct PaperSaveable: Codable, Hashable {

    let paperId: String?
    let title: String?
    let abstract: String?
    let pdfURL: String?
    let fieldsOfStudy: [String]?
    let publicationDate: String?
    let authors: [String]?
    let tldr: String?
    let doi: String?
    let publicationTypes: [String]?

    init(from paper: Paper) {
        self.paperId = paper.paperId
        self.title = paper.title
        self.abstract = paper.abstract
        self.pdfURL = paper.openAccessPdf.url
        self.fieldsOfStudy = paper.fieldsOfStudy
        self.publicationDate = paper.publicationDate
        self.authors = paper.authors?.compactMap { $0.name }
        self.tldr = paper.tldr?.text
        self.doi = paper.externalIds?.DOI
        self.publicationTypes = paper.publicationTypes
    }
    
    func toPaper() -> Paper {
            return Paper(
                paperId: self.paperId,
                title: self.title,
                abstract: self.abstract,
                openAccessPdf: Pdf(url: self.pdfURL ?? ""),
                fieldsOfStudy: self.fieldsOfStudy,
                publicationDate: self.publicationDate,
                authors: self.authors?.map { Author(authorId: nil, name: $0) },
                tldr: self.tldr != nil ? Tldr(text: self.tldr) : nil,
                externalIds: ExternalIds(DOI: self.doi, PubMed: nil, ArXiv: nil),
                publicationTypes: self.publicationTypes
            )
        }
}
