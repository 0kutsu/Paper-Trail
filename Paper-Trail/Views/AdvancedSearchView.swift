//
//  AdvancedSearchView.swift
//  Paper-Trail
//
//  Created by Angelina Cheng on 11/27/25.
//

import Foundation
import SwiftUI

struct AdvancedSearchView: View {
    @Environment(PaperTrailViewModel.self) var vm: PaperTrailViewModel
    @State var termSearch: String = ""
    @State var authorSearch: String = ""
    @State var citationCount: String = ""
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var showOnlyOpenAccess: Bool = false
    
    @State var isInvalid: Bool = false
    @State var tooManyRequests: Bool = false
    
    var body: some View {
        Text("Advanced Search")
            .font(.title)
            .bold()
            .padding()
        
        VStack {
            HStack {
                TextField(
                    "Search key terms...",
                    text: $termSearch
                )
                .padding(.leading, 20)
                .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    if termSearch != "" {
                        vm.addTag(termSearch)
                        termSearch = ""
                    }
                }) {
                    Text("Add Term")
                        .padding(.trailing, 20)
                }
            }
            .padding(.vertical, 5)
            
            HStack {
                TextField(
                    "Search for author...",
                    text: $authorSearch
                )
                .padding(.leading, 20)
                .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    if authorSearch != "" {
                        vm.addAuthor(authorSearch)
                        authorSearch = ""
                    }
                }) {
                    Text("Add Author")
                        .padding(.trailing, 20)
                }
            }
            .padding(.vertical, 5)
            
            TextField(
                "Minimum citation count...",
                text: $citationCount
            )
            .padding(.horizontal)
            .padding(5)
            .textFieldStyle(.roundedBorder)
            .padding(.vertical, 5)
            
            DatePicker(
                "Publication Start Date",
                selection: $startDate,
                displayedComponents: [.date]
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            
            DatePicker(
                "Publication End Date",
                selection: $endDate,
                displayedComponents: [.date]
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            
            Toggle(isOn: $showOnlyOpenAccess) {
                Text("Show only open access papers?")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
        }
        
        Text("Added Key Terms:")
            .padding(15)
            .bold()
        LazyVGrid (columns: [
            GridItem(.flexible(minimum: 50, maximum: .infinity)),
            GridItem(.flexible(minimum: 50, maximum: .infinity))
        ], content: {
            ForEach(Array(vm.tags), id: \.self) { term in
                Button(action: {
                    vm.removeTag(term)
                }) {
                    AddedTagView(tagName: term)
                        .buttonStyle(.bordered)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
        })
        .padding(.bottom)
        
        Text("Added Authors:")
            .padding(15)
            .bold()
        LazyVGrid (columns: [
            GridItem(.flexible(minimum: 50, maximum: .infinity)),
            GridItem(.flexible(minimum: 50, maximum: .infinity))
        ], content: {
            ForEach(Array(vm.authors), id: \.self) { author in
                Button(action: {
                    vm.removeAuthor(author)
                }) {
                    AddedTagView(tagName: author)
                        .buttonStyle(.bordered)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
        })
        .padding(.bottom)
        
        Spacer()
        
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
        
        VStack {
            Button(action: {
                if vm.tags.isEmpty && vm.authors.isEmpty {
                    isInvalid = true
                } else {
                    Task {
                        do {
                            let returnedPapers = try await vm.getAdvancedSearch(
                                tags: Array(vm.tags),
                                authors: Array(vm.authors),
                                citationCount: citationCount,
                                startDate: startDate,
                                endDate: endDate,
                                onlyOpenAccess: showOnlyOpenAccess
                            )
                            if let returnedPapers {
                                if !returnedPapers.isEmpty {
                                    vm.papers = returnedPapers
                                    isInvalid = false
                                } else {
                                    isInvalid = true
                                }
                                tooManyRequests = false
                            } else {
                                isInvalid = true
                                tooManyRequests = true
                            }
                        } catch {
                            isInvalid = true
                        }
                    }
                }
            }) {
                Text("Find papers")
                    .foregroundColor(.white)
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .background(Color.blue)
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
            .disabled(vm.papers.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        AdvancedSearchView()
    }
    .environment(PaperTrailViewModel())
}
