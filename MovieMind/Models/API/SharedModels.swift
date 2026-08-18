//
//  SharedModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

struct Genre: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
}

struct Images: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var logos: [ImageDetails] = []
    @Fallback var posters: [ImageDetails] = []

    /// The language-neutral poster: no text baked into the artwork.
    var bestPoster: String? {
        posters.first { $0.iso6391 == nil }?.filePath
    }

    func bestLogo(language: String = "en") -> String? {
        logos.first { $0.iso6391 == language }?.filePath ?? logos.first?.filePath
    }
}

struct ImageDetails: Decodable, Sendable {
    /// Stays optional: `nil` marks the language-neutral asset, which `bestPoster` relies on.
    let iso6391: String?
    let filePath: String?
}

/// Providers keyed by region code — "TR", "US", …
struct WatchProviderResponse: Decodable, Sendable {
    let id: Int?
    @Fallback var results: [String: CountryWatchProviders] = [:]
}

struct CountryWatchProviders: Decodable, Sendable {
    @Fallback var flatrate: [WatchProvider] = []
    @Fallback var rent: [WatchProvider] = []
    @Fallback var buy: [WatchProvider] = []
    @Fallback var free: [WatchProvider] = []
    @Fallback var ads: [WatchProvider] = []

    var all: [WatchProvider] { flatrate + free + ads + rent + buy }
}

struct WatchProvider: Decodable, Identifiable, Sendable {
    let providerId: Int?
    @Fallback var providerName: String = ""
    let logoPath: String?
    /// Stays optional: "no priority given" sorts last, which 0 would not.
    let displayPriority: Int?

    var id: String { "\(providerId ?? 0)-\(providerName)" }
}
