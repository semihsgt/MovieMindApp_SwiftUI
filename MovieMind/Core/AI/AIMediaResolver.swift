//
//  AIMediaResolver.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import Foundation

struct AIRecommendation: Decodable, Sendable {
    let title: String
    let year: String?
    let mediaType: String

    /// The shape both the chat and the recommendation service ask Gemini for.
    static let schema = JSONSchema.object(
        properties: [
            ("title", .string),
            ("year", .string),
            ("mediaType", .string)
        ],
        required: ["title", "mediaType"]
    )

    static let listSchema = JSONSchema.array(items: schema)
}

/// Turns the titles the AI replies with into real TMDB items.
enum AIMediaResolver {

    static func resolve(_ recommendations: [AIRecommendation],
                        excludingTitles excluded: Set<String> = [],
                        using network: SearchServicing) async -> [MediaItem] {
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
                              using network: SearchServicing) async -> MediaItem? {
        let mediaType: MediaType = recommendation.mediaType.lowercased() == "tv" ? .tv : .movie
        let endpoint: SearchEndpoint = mediaType == .tv
            ? .searchTV(query: recommendation.title)
            : .searchMovies(query: recommendation.title)

        guard let response = try? await network.fetchSearch(for: endpoint),
              !response.results.isEmpty else {
            return nil
        }

        let results = response.results

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
