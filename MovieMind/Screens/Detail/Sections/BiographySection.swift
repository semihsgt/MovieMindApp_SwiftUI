//
//  BiographySection.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

struct BiographySection: View {

    let biography: String
    @State private var isExpanded = false

    var body: some View {
        if !biography.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Biography")
                    .font(.title3.bold())
                    .fontDesign(.rounded)

                Text(biography)
                    .font(.body)
                    .lineLimit(isExpanded ? nil : 6)

                Button(isExpanded ? "Read Less" : "Read More") {
                    withAnimation(.easeInOut) { isExpanded.toggle() }
                }
                .font(.subheadline.bold())
                .tint(.white)
            }
            .foregroundStyle(.white.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}

#Preview("Long") {
    BiographySection(biography: String(repeating: "Millie Bobby Brown is an English actress and producer. ", count: 12))
}

#Preview("Empty") {
    BiographySection(biography: "")
}
