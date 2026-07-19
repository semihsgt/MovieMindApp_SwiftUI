//
//  DetailSections.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation
import SwiftUI

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

                    VStack(alignment: .leading, spacing: 4) {
                        if let season = episode.seasonNumber, let number = episode.episodeNumber {
                            Text("S\(season) • E\(number)")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        Text(episode.name ?? "Untitled")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        if let airDate = episode.airDate?.toDate()?.relativeReleaseString() {
                            Text(airDate)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}


struct SeasonsSection: View {
    let seasons: [Season]?

    var body: some View {
        if let seasons, !seasons.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Seasons")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(seasons) { season in
                            VStack(alignment: .leading, spacing: 4) {
                                AsyncPoster(path: season.posterPath,
                                            width: 100, height: 150,
                                            size: .w200)
                                Text(season.name ?? "Season \(season.seasonNumber ?? 0)")
                                    .font(.caption.bold())
                                    .lineLimit(1)
                                if let count = season.episodeCount {
                                    Text("\(count) episodes")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(width: 100)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct CollectionBanner: View {
    let collection: BelongsToCollection?

    var body: some View {
        if let collection {
            ZStack(alignment: .bottomLeading) {
                AsyncPoster(path: collection.backdropPath,
                            height: 120,
                            cornerRadius: 20)

                LinearGradient(colors: [.clear, .black.opacity(0.8)],
                               startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Text(collection.name ?? "Collection")
                    .font(.headline.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .padding(12)
            }
            .padding(.horizontal)
        }
    }
}


struct OverviewSection: View {
    let tagline: String?
    let overview: String?

    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 8) {
                if let tagline, !tagline.isEmpty {
                    Text(tagline)
                        .font(.subheadline.italic())
                        .foregroundStyle(.white.opacity(0.7))
                }
                if let overview, !overview.isEmpty {
                    Text(overview)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }

    private var hasContent: Bool {
        overview?.isEmpty == false || tagline?.isEmpty == false
    }
}


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


struct WatchProvidersSection: View {
    let providers: CountryWatchProviders?

    private var allProviders: [WatchProvider] {
        guard let providers else { return [] }
        let combined = (providers.flatrate ?? []) + (providers.free ?? [])
        + (providers.ads ?? []) + (providers.rent ?? []) + (providers.buy ?? [])

        var seen = Set<Int>()
        return combined
            .filter { provider in
                guard let id = provider.providerId else { return false }
                return seen.insert(id).inserted
            }
            .sorted { ($0.displayPriority ?? .max) < ($1.displayPriority ?? .max) }
    }

    var body: some View {
        if !allProviders.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Where to Watch")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(allProviders) { provider in
                            AsyncPoster(path: provider.logoPath,
                                        width: 50, height: 50,
                                        cornerRadius: 12,
                                        size: .w200)
                        }
                    }
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}


struct BiographySection: View {
    let biography: String?
    @State private var isExpanded = false

    var body: some View {
        if let biography, !biography.isEmpty {
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
            }
        }
    }
}


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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}


struct CastSection: View {
    let cast: [CastMember]?

    var body: some View {
        if let cast, !cast.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Cast")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(Array(cast.prefix(15)), id: \.uniqueId) { member in
                            if let personId = member.id {
                                NavigationLink(value: MediaRoute(id: personId, mediaType: .person)) {
                                    VStack(spacing: 4) {
                                        AsyncPoster(path: member.profilePath,
                                                    width: 100, height: 150,
                                                    size: .w200)
                                        Text(member.name ?? "")
                                            .font(.caption.bold())
                                            .lineLimit(1)
                                        Text(member.character ?? "")
                                            .font(.caption2)
                                            .foregroundStyle(.white.opacity(0.6))
                                            .lineLimit(1)
                                    }
                                    .frame(width: 100)
                                    .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    DetailPageView(id: 640146, mediaType: .movie)
}
