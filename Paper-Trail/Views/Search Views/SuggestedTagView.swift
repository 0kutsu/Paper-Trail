//
//  SuggestedTagView.swift
//  Paper-Trail
//
//  Created by Angelina Cheng on 11/26/25.
//

import Foundation
import SwiftUI

struct SuggestedTagView: View {
    @Environment(PaperTrailViewModel.self) var vm: PaperTrailViewModel
    @State var tagName: String
    
    var body: some View {
        HStack {
            Text(tagName)
                .foregroundColor(.gray)
        }
        .padding(5)
        .padding(.horizontal, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.gray, lineWidth: 2)
        )
    }
}

#Preview {
    SuggestedTagView(tagName: "bye")
        .environment(PaperTrailViewModel())
}
