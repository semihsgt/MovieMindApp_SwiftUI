//
//  GenreChipsRow.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

struct GenreChipsRow: View {

    let names: [String]

    var body: some View {
        if !names.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(names, id: \.self) { name in
                        Text(name)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.12), in: .capsule)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Genres: \(names.joined(separator: ", "))")
            }
        }
    }
}

#Preview("Several") {
    GenreChipsRow(names: ["Science Fiction", "Adventure", "Drama", "Thriller"])
}

#Preview("Empty") {
    GenreChipsRow(names: [])
}
