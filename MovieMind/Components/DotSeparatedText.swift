//
//  DotSeparatedText.swift
//  MovieMind
//
//  Created by Semih Söğüt on 13.08.2026.
//

import SwiftUI

/// Renders "2024 • 2h 46m • ★ 8.2" from a list of strings.
///
/// Carries no padding, alignment or font of its own so the caller keeps control
/// of how the row sits — the hero card centres it, the detail screen leads it.
struct DotSeparatedText: View {

    let items: [String]
    var spacing: CGFloat = 6

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(items.indices, id: \.self) { index in
                if index > 0 {
                    Text("•").foregroundStyle(.white.opacity(0.4))
                }
                Text(items[index])
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        DotSeparatedText(items: ["2024", "2h 46m", "★ 8.2"])
        DotSeparatedText(items: ["Movie", "Science Fiction", "Adventure", "18+"])
        DotSeparatedText(items: ["Person"])
    }
    .font(.subheadline)
    .foregroundStyle(.white.opacity(0.8))
}
