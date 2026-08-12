//
//  MetadataRow.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

/// Year • runtime • rating • status, separated by dots.
struct MetadataRow: View {

    let items: [String]

    var body: some View {
        if !items.isEmpty {
            HStack(spacing: 6) {
                ForEach(items.indices, id: \.self) { index in
                    if index > 0 {
                        Text("•").foregroundStyle(.white.opacity(0.4))
                    }
                    Text(items[index])
                        .lineLimit(1)
                }
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
