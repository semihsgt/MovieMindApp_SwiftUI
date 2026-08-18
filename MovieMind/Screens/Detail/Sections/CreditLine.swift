//
//  CreditLine.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

/// A single labelled credit line, e.g. "Director Denis Villeneuve".
struct CreditLine: View {

    let label: String
    let names: [String]

    var body: some View {
        if !names.isEmpty {
            HStack(alignment: .top, spacing: 6) {
                Text(label)
                    .foregroundStyle(.white.opacity(0.6))
                Text(names.joined(separator: ", "))
                    .foregroundStyle(.white)
            }
            .font(.subheadline)
            .accessibilityElement(children: .combine)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}

#Preview("One name") {
    CreditLine(label: "Director", names: ["Denis Villeneuve"])
}

#Preview("Several names") {
    CreditLine(label: "Created by", names: ["Craig Mazin", "Neil Druckmann"])
}

#Preview("Empty") {
    CreditLine(label: "Director", names: [])
}
