//
//  OverviewSection.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

struct OverviewSection: View {

    let tagline: String
    let overview: String

    var body: some View {
        if !tagline.isEmpty || !overview.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                if !tagline.isEmpty {
                    Text(tagline)
                        .font(.subheadline.italic())
                        .foregroundStyle(.white.opacity(0.7))
                }

                if !overview.isEmpty {
                    Text(overview)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}

#Preview("Both") {
    OverviewSection(tagline: "Long live the fighters.",
                    overview: "Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.")
}

#Preview("Overview only") {
    OverviewSection(tagline: "", overview: "A short synopsis with no tagline attached.")
}

#Preview("Empty") {
    OverviewSection(tagline: "", overview: "")
}
