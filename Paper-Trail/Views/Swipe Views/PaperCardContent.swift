//
//  PaperCardCountent.swift
//  Paper-Trail
//
//  Created by Mati Okutsu on 12/1/25.
//

import SwiftUI
import Foundation

struct PaperCardContent: View {
    let paper: Paper
    let hasSeen: Bool
    let showSeen: Bool
    @Environment(\.openURL) private var openURL

    @State private var isAbstractExpanded: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 10) {


                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(paper.title ?? "Untitled paper")
                            .font(.headline)
                            .multilineTextAlignment(.leading)

                        if let doiURL = paper.doiURL {
                            Button {
                                openURL(doiURL)
                            } label: {
                                Text("DOI link")
                                    .font(.subheadline)
                                    .underline()
                            }
                        }

                        if !paper.authorNames.isEmpty {
                            Text(paper.authorNames.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        if let pubDate = paper.publicationDateFormatted {
                            Text("Published: \(pubDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if let type = paper.primaryPublicationType {
                            Text(type)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                    
                    if (showSeen) {
                        Text(hasSeen ? "Seen" : "New")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(hasSeen
                                          ? Color.orange.opacity(0.2)
                                          : Color.green.opacity(0.2))
                            )
                    }
                }

            
                if let fields = paper.fieldsOfStudy, !fields.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(fields.prefix(4), id: \.self) { field in
                                Text(field)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.black.opacity(0.05))
                                    )
                            }
                        }
                    }
                }

                Divider()

                
                if let tldr = paper.tldrText {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("TL;DR")
                            .font(.subheadline.bold())

                        Text(tldr)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()
                }


                if let abstract = paper.abstract, !abstract.isEmpty {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("Abstract")
                                .font(.subheadline.bold())
                            Spacer()
                            Button {
                                isAbstractExpanded.toggle()
                            } label: {
                                Image(systemName: isAbstractExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption.bold())
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }

                        Text(abstract)
                            .font(.subheadline)
                            .lineLimit(isAbstractExpanded ? nil : 3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Abstract")
                            .font(.subheadline.bold())
                        Text("Abstract cannot be retrieved. Refer to DOI link to learn more.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }


                if let pdfURL = paper.pdfURL {
                    Button {
                        openURL(pdfURL)
                    } label: {
                        HStack {
                            Image(systemName: "doc.richtext")
                            Text("View PDF")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }
            .padding(.bottom, 8)
        }
    }
}
