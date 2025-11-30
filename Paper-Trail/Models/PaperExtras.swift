//
//  PaperExtras.swift
//  PaperTrailFinal
//
//  Created by Arina Velieva on 11/27/25.
//

import Foundation


extension Paper {

    var stableID: String {
        if let paperId, !paperId.isEmpty {
            return paperId
        }
        if let title, !title.isEmpty {
            return "title::\(title)"
        }
        return UUID().uuidString
    }

    var authorNames: [String] {
        authors?.compactMap { $0.name } ?? []
    }


    var publicationDateFormatted: String? {
        guard let raw = publicationDate, !raw.isEmpty else { return nil }

        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let prettyFormatter = DateFormatter()
        prettyFormatter.locale = Locale(identifier: "en_US_POSIX")
        prettyFormatter.dateStyle = .medium

        if raw.count == 10 {
            isoFormatter.dateFormat = "yyyy-MM-dd"
            if let date = isoFormatter.date(from: raw) {
                return prettyFormatter.string(from: date)
            }
        }

        if raw.count == 4 {
            return raw
        }

        return raw
    }

    var primaryPublicationType: String? {
        guard let raw = publicationTypes?.first?.lowercased() else { return nil }

        switch raw {
        case "journalarticle":
            return "Article"
        case "book":
            return "Book"
        case "bookchapter":
            return "Chapter"
        case "thesis":
            return "Thesis"
        default:
            return raw.capitalized
        }
    }

    
    var doiURL: URL? {
        if let ids = externalIds {
            if let doi = ids.DOI, !doi.isEmpty {
                return URL(string: "https://doi.org/\(doi)")
            }
            if let pmid = ids.PubMed, !pmid.isEmpty {
                return URL(string: "https://pubmed.ncbi.nlm.nih.gov/\(pmid)/")
            }
            if let arxiv = ids.ArXiv, !arxiv.isEmpty {
                return URL(string: "https://arxiv.org/abs/\(arxiv)")
            }
        }
        
        if let paperId, !paperId.isEmpty {
            return URL(string: "https://www.semanticscholar.org/p/\(paperId)")
        }
        return nil
    }

    var pdfURL: URL? {
        URL(string: openAccessPdf.url)
    }

    var tldrText: String? {
        if let text = tldr?.text, !text.isEmpty {
            return text
        }
        return nil
    }
}

fileprivate func + (lhs: Substring, rhs: String) -> String {
    String(lhs) + rhs
}
