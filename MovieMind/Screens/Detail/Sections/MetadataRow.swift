//
//  MetadataRow.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

/// Year • runtime • rating • status, under the detail hero.
struct MetadataRow: View {

    let items: [String]

    var body: some View {
        if !items.isEmpty {
            HStack {
                DotSeparatedText(items: items)
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal)
        }
    }
}

#Preview("Movie") {
    MetadataRow(items: ["2024", "2h 46m", "★ 8.2"])
}

#Preview("TV, still running") {
    MetadataRow(items: ["2023", "2 Seasons", "★ 8.5"])
}

#Preview("Empty") {
    MetadataRow(items: [])
}
