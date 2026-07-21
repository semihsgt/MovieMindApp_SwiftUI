//
//  AIRecommendationService.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import Foundation

struct WatchlistSeed: Sendable, Hashable {
    let title: String
    let mediaType: MediaType
}

struct AIRecommendation: Decodable, Sendable {
    let title: String
    let year: String?
    let mediaType: String
}

enum AIMediaResolver {

    static func resolve(_ recommendations: [AIRecommendation],
                        excludingTitles excluded: Set<String> = [],
                        using network: NetworkServicing) async -> [MediaItem] {
        let ordered = await withTaskGroup(of: (Int, MediaItem?).self) { group -> [MediaItem] in
            for (index, recommendation) in recommendations.enumerated() {
                group.addTask {
                    (index, await match(recommendation, using: network))
                }
            }

            var collected: [(Int, MediaItem)] = []
            for await (index, item) in group {
                if let item { collected.append((index, item)) }
            }
            return collected.sorted { $0.0 < $1.0 }.map(\.1)
        }

        var seenIds = Set<Int>()
        var result: [MediaItem] = []

        for item in ordered {
            guard let id = item.id, seenIds.insert(id).inserted else { continue }
            guard !excluded.contains(item.displayName.lowercased()) else { continue }
            result.append(item)
        }

        return result
    }

    private static func match(_ recommendation: AIRecommendation,
                              using network: NetworkServicing) async -> MediaItem? {
        let mediaType: MediaType = recommendation.mediaType.lowercased() == "tv" ? .tv : .movie
        let endpoint: SearchEndpoint = mediaType == .tv
            ? .searchTV(query: recommendation.title)
            : .searchMovies(query: recommendation.title)

        guard let response = try? await network.fetchSearch(for: endpoint),
              let results = response.results,
              !results.isEmpty else {
            return nil
        }

        let picked: MediaItem
        if let year = recommendation.year,
           let yearMatch = results.first(where: { ($0.displayDate ?? "").hasPrefix(year) }) {
            picked = yearMatch
        } else {
            picked = results[0]
        }

        var copy = picked
        copy.mediaType = mediaType
        return copy
    }
}

actor AIRecommendationService {

    static let shared = AIRecommendationService()

    private let ai: AIServicing
    private let network: NetworkServicing

    init(ai: AIServicing = GeminiService.shared,
         network: NetworkServicing = NetworkManager.shared) {
        self.ai = ai
        self.network = network
    }

    func recommend(from seeds: [WatchlistSeed], limit: Int = 12) async throws -> [MediaItem] {
        guard !seeds.isEmpty else { return [] }

        let schema = JSONSchema.array(items: .object(
            properties: [
                ("title", .string),
                ("year", .string),
                ("mediaType", .string)
            ],
            required: ["title", "mediaType"]
        ))

        let recommendations = try await ai.generate(
            prompt: Self.buildPrompt(seeds: seeds, limit: limit),
            schema: schema,
            as: [AIRecommendation].self
        )

        let excluded = Set(seeds.map { $0.title.lowercased() })
        return await AIMediaResolver.resolve(recommendations, excludingTitles: excluded, using: network)
    }

    private static func buildPrompt(seeds: [WatchlistSeed], limit: Int) -> String {
        let list = seeds
            .map { "- \($0.title) (\($0.mediaType == .tv ? "TV" : "Movie"))" }
            .joined(separator: "\n")

        return """
        A user saved these titles to their movie/TV watchlist:
        \(list)

        Recommend \(limit) movies or TV shows they are likely to enjoy, based on shared \
        genres, themes, tone, era, or creators. Do not include any title already in the list. \
        Prefer well-known, findable titles over very obscure ones. For each recommendation \
        provide the exact commonly-used English title, its 4-digit release year, and a \
        mediaType of either "movie" or "tv".
        """
    }
}
