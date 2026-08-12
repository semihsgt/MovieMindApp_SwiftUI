//
//  EpisodeSection.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

/// Next or last episode to air. Renders nothing when the show has neither.
struct EpisodeSection: View {

    let title: String
    let episode: TEpisodeToAir?

    var body: some View {
        if let episode {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    AsyncPoster(path: episode.stillPath,
                                width: 120, height: 68,
                                cornerRadius: 10,
                                size: .w200)

                    details(for: episode)

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }

    private func details(for episode: TEpisodeToAir) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if episode.hasNumbering {
                Text("S\(episode.seasonNumber) • E\(episode.episodeNumber)")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.6))
            }

            Text(episode.displayName)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .lineLimit(2)

            if let airDate = episode.airDate?.toDate()?.relativeReleaseString() {
                Text(airDate)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

#Preview("Next episode") {
    EpisodeSection(title: "Next Episode", episode: .preview)
}

#Preview("Missing") {
    EpisodeSection(title: "Next Episode", episode: nil)
}
