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
