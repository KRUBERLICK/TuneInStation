//
//  TagsView.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import SwiftUI

struct TagsView: View {
    let allTags: [String]
    @Binding var activeTags: Set<String>
    
    var body: some View {
        ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(allTags, id: \.self) { tag in
                        Button {
                            if activeTags.contains(tag) {
                                activeTags.remove(tag)
                            } else {
                                activeTags.insert(tag)
                            }
                        } label: {
                            Text("#\(tag)")
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(activeTags.contains(tag) ? Color(hex: "FA1515") : Color.gray)
                                )
                        }
                    }
                }
            }
            .scrollIndicators(.never)
    }
}
