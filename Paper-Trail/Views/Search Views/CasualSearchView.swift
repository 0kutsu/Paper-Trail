//
//  CasualSearchView.swift
//  Paper-Trail
//
//  Created by Angelina Cheng on 11/26/25.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct CasualSearchView: View {
    @Environment(PaperTrailViewModel.self) var vm: PaperTrailViewModel
    @State var input: String = ""
    @State var suggested: Set<String> = suggestedTags
    @State var isInvalid: Bool = false
    @State var tooManyRequests: Bool = false
    
    @State var isShowingSheet: Bool = false
    @State var clickedSearch: Bool = false
    
    var body: some View {
        VStack {
            
            
            VStack {
                Text("Quick Search")
                    .font(.title)
                    .bold()
                    .padding()
                
                
                
                
                
                VStack {
                    Text("Suggested Tags:")
                        .padding(15)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 50, maximum: .infinity)),
                        GridItem(.flexible(minimum: 50, maximum: .infinity))
                    ]) {
                        ForEach(Array(suggested), id: \.self) { tag in
                            Button {
                                vm.addTag(tag)
                                suggested.remove(tag)
                            } label: {
                                SuggestedTagView(tagName: tag)
                            }
                        }
                    }
                    .frame(minHeight: 150)
                    .animation(.default, value: suggested)
                    .padding(.bottom)
                }
                .padding(.horizontal)
                
                HStack {
                    TextField(
                        "Search...",
                        text: $input
                    )
                    .padding(.leading)
                    .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        if input != "" {
                            vm.addTag(input)
                            input = ""
                        }
                    }) {
                        Text("Add Tag")
                    }
                }
                .padding(.horizontal)
            }
            
            Text("Added Tags:")
                .padding(15)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid (columns: [
                GridItem(.flexible(minimum: 50, maximum: .infinity)),
                GridItem(.flexible(minimum: 50, maximum: .infinity))
            ], content: {
                ForEach(Array(vm.tags), id: \.self) { tag in
                    Button(action: {
                        if suggestedTags.contains(tag) {
                            suggested.insert(tag)
                        }
                        vm.removeTag(tag)
                    }) {
                        AddedTagView(tagName: tag)
                            .buttonStyle(.bordered)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                }
            })
            .padding(.bottom)
            
            Spacer()
            
            
            VStack {
                isInvalid ? (
                    tooManyRequests ?
                    Text("Too many requests. Please try again later.")
                        .padding(5)
                        .foregroundColor(.red)
                    : Text("No papers match your search.")
                        .padding(5)
                        .foregroundColor(.red)
                ) :
                Text("")
                    .padding(5)
                    .foregroundColor(.red)
                
                Text("Swipe up for advanced search")
                    .gesture(DragGesture(minimumDistance: 3.0)
                        .onEnded { value in
                            switch(value.translation.width, value.translation.height) {
                                case (-100...100, ...0): isShowingSheet = true
                                default: break
                            }
                        }
                    )
                    .foregroundStyle(Color.secondary)
                    .padding(.bottom)
                
                Button(action: {
                    Task {
                        if !clickedSearch {
                            clickedSearch = true
                            try await vm.wait()
                        }
                        
                        if vm.tags.isEmpty {
                            isInvalid = true
                            clickedSearch = false
                        } else {
                            Task {
                                do {
                                    clickedSearch = true
                                    let returnedPapers = try await vm.getCasualSearch(input: vm.tags)
                                    if let returnedPapers {
                                        if !returnedPapers.isEmpty {
                                            vm.papers = returnedPapers
                                            isInvalid = false
                                        } else {
                                            isInvalid = true
                                        }
                                        tooManyRequests = false
                                        clickedSearch = false
                                    } else {
                                        isInvalid = true
                                        tooManyRequests = true
                                        clickedSearch = false
                                    }
                                } catch {
                                    isInvalid = true
                                    clickedSearch = false
                                }
                            }
                        }
                    }
                }) {
                    Text("Find Papers")
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .background(clickedSearch ? Color.gray : Color.blue)
                .cornerRadius(8)
                .padding(.horizontal)

                NavigationLink {
                    SwipeDeckView()
                } label: {
                    Text("Start viewing articles")
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .background(vm.papers.isEmpty ? Color.gray : Color.green)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(vm.papers.isEmpty)
            }
            
            
        }
        .sheet(isPresented: $isShowingSheet, onDismiss: didDismiss) {
            NavigationStack {
                AdvancedSearchView()
            }
            .environment(vm)
        }
    }
    
    func didDismiss() {
        isShowingSheet = false
    }
}

#Preview {
    NavigationStack {
        CasualSearchView()
    }
    .environment(PaperTrailViewModel())
}
