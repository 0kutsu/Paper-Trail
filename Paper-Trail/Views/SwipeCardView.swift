//
//  SwipeCardView.swift
//  PaperTrailFinal
//
//  Created by Arina Velieva on 11/27/25.
//

import SwiftUI

enum SwipeDirection {
    case left
    case right
}

struct SwipeCardView: View {
    let paper: Paper
    let hasSeen: Bool
    let onSwipe: (SwipeDirection) -> Void

    @State private var offset: CGSize = .zero
    @GestureState private var isDragging = false

    private let swipeThreshold: CGFloat = 100

    private var cardBackground: Color {
        hasSeen ? Color(.systemGray6) : Color(.systemBlue).opacity(0.15)
    }

    private var cardBorder: Color {
        hasSeen ? Color(.systemGray4) : Color(.systemBlue).opacity(0.4)
    }

    private var swipeColor: Color {
        let progress = min(abs(offset.width) / 200, 1.0)

        if offset.width > 0 {
            return Color.green.opacity(Double(progress) * 0.35)
        } else if offset.width < 0 {
            return Color.red.opacity(Double(progress) * 0.35)
        } else {
            return .clear
        }
    }

    var body: some View {
        let drag = DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                handleDragEnd(translation: value.translation)
            }

        ZStack(alignment: .topLeading) {
            

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(cardBorder, lineWidth: 1.5)
                )
                .shadow(radius: 6)

            
            RoundedRectangle(cornerRadius: 18)
                .fill(swipeColor)
                .allowsHitTesting(false)

            
            Rectangle()
                .fill(hasSeen ? Color.orange.opacity(0.6) : Color.green.opacity(0.7))
                .frame(height: 4)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 4)


            PaperCardContent(paper: paper, hasSeen: hasSeen)
                .padding()
        }
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width) / 20.0))
        .scaleEffect(isDragging ? 1.02 : 1.0)
        .animation(.spring(), value: offset)
        .gesture(drag)
        .padding(.horizontal)
    }


    private func handleDragEnd(translation: CGSize) {
        if translation.width > swipeThreshold {
            withAnimation(.easeOut) {
                offset = CGSize(width: 800, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                offset = .zero
                onSwipe(.right)
            }
        } else if translation.width < -swipeThreshold {
            // Left swipe → discard
            withAnimation(.easeOut) {
                offset = CGSize(width: -800, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                offset = .zero
                onSwipe(.left)
            }
        } else {
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }
}



struct PaperCardContent: View {
    let paper: Paper
    let hasSeen: Bool
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
