//
//  AIShortcutCard.swift
//  MovieMind
//
//  Created by Semih Söğüt on 11.08.2026.
//

import SwiftUI

/// Entry point to the AI chat, shown between the Home sections.
struct AIShortcutCard: View {

    var body: some View {
        NavigationLink(value: AskAIRoute(query: "")) {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.red.gradient, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Ask Movie Mind AI")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text("Describe a mood or vibe and get personalized picks.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.5))
                    .accessibilityHidden(true)
            }
            .padding()
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AIShortcutCard()
            .padding()
    }
}

