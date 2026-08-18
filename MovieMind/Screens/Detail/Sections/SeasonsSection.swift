//
//  SeasonsSection.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

struct SeasonsSection: View {

    let seasons: [Season]

    var body: some View {
        if !seasons.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Seasons")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(seasons) { season in
                            card(for: season)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func card(for season: Season) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncPoster(path: season.posterPath,
                        width: 100, height: 150,
                        size: .w200)

            Text(season.displayName)
                .font(.caption.bold())
                .lineLimit(1)

            if season.episodeCount > 0 {
                Text("\(season.episodeCount) episodes")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .foregroundStyle(.white)
        .frame(width: 100)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(season.episodeCount > 0
                            ? "\(season.displayName), \(season.episodeCount) episodes"
                            : season.displayName)
    }
}

#Preview("Seasons") {
    SeasonsSection(seasons: [.preview, .previewUnnamed])
        .frame(height: 300)
}

#Preview("Empty") {
    SeasonsSection(seasons: [])
}
