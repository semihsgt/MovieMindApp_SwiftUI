//
//  AIRecommendationService.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import Foundation

struct LibrarySeed: Sendable, Hashable {
    let title: String
    let mediaType: MediaType
}

protocol AIRecommending: Sendable {
    func recommend(from seeds: [LibrarySeed]) async throws -> [MediaItem]
}

actor AIRecommendationService: AIRecommending {

    static let shared = AIRecommendationService()
    private static let recommendationLimit = 12
    private let ai: AIServicing
    private let network: SearchServicing

    init(ai: AIServicing = GeminiService.shared,
         network: SearchServicing = NetworkManager.shared) {
        self.ai = ai
        self.network = network
    }

    func recommend(from seeds: [LibrarySeed]) async throws -> [MediaItem] {
        guard !seeds.isEmpty else { return [] }

        let recommendations = try await ai.generate(
            prompt: Self.buildPrompt(seeds: seeds, limit: Self.recommendationLimit),
            schema: AIRecommendation.listSchema,
            as: [AIRecommendation].self
        )

        let excluded = Set(seeds.map { $0.title.lowercased() })
        return await AIMediaResolver.resolve(recommendations, excludingTitles: excluded, using: network)
    }

    private static func buildPrompt(seeds: [LibrarySeed], limit: Int) -> String {
        let list = seeds
            .map { "- \($0.title) (\($0.mediaType == .tv ? "TV" : "Movie"))" }
            .joined(separator: "\n")

        return """
        A user saved these titles to their movie/TV library:
        \(list)

        Recommend \(limit) movies or TV shows they are likely to enjoy, based on shared \
        genres, themes, tone, era, or creators. Do not include any title already in the list. \
        Prefer well-known, findable titles over very obscure ones. For each recommendation \
        provide the exact commonly-used English title, its 4-digit release year, and a \
        mediaType of either "movie" or "tv".
        """
    }
}
