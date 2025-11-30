//
//  SwipeDeckView.swift
//  PaperTrailFinal
//
//  Created by Arina Velieva on 11/27/25.
//


import SwiftUI


struct SwipeDeckView: View {
    @Environment(PaperTrailViewModel.self) var vm: PaperTrailViewModel
    @State private var library = LibraryStore.shared

    @State private var currentIndex: Int = 0
    @State private var showCollectionPicker: Bool = false


    private var papersToShow: [Paper] {
        vm.papers.filter { !library.isFavorite($0) }
    }


    private var currentPaper: Paper? {
        guard currentIndex < papersToShow.count else { return nil }
        return papersToShow[currentIndex]
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Swipe Articles")
                    .font(.title2)
                    .bold()
                Spacer()
                if currentPaper != nil {
                    Button {
                        showCollectionPicker = true
                    } label: {
                        Label("Add to Collection", systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            Spacer()


            if let paper = currentPaper {
                SwipeCardView(
                    paper: paper,
                    hasSeen: library.hasSeen(paper),
                    onSwipe: handleSwipe(_:)
                )
                .padding()
                .onAppear {
                   
                    library.markSeen(paper)
                }
            } else {
                VStack(spacing: 8) {
                    Text("No more results")
                        .font(.title3)
                        .bold()
                    Text("Try adjusting your tags or running a new search.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }

            Spacer()
        }
        .sheet(isPresented: $showCollectionPicker) {
            if let paper = currentPaper {
                CollectionPickerView(paper: paper, library: library)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }


    private func handleSwipe(_ direction: SwipeDirection) {
        guard let paper = currentPaper else { return }

        switch direction {
        case .right:
            library.addToFavorites(paper)
        case .left:
            library.markSeen(paper)
        }

        withAnimation {
            currentIndex += 1
        }
    }
}
