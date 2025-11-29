//
//  AddedTagView.swift
//  Paper-Trail
//
//  Created by Angelina Cheng on 11/26/25.
//

import Foundation
import SwiftUI

struct AddedTagView: View {
    @Environment(PaperTrailViewModel.self) var vm: PaperTrailViewModel
    @State var tagName: String
    
    var body: some View {
        HStack {
            Text(tagName)
                .foregroundColor(.white)
            Image(systemName: "x.circle")
                .foregroundColor(.white)
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
    AddedTagView(tagName: "bye")
        .environment(PaperTrailViewModel())
}
