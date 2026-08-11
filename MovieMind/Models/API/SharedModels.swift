//
//  SharedModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

struct Genre: Decodable, Identifiable {
    let id: Int?
    let name: String?
}

struct Images: Decodable, Identifiable {
    let id: Int?
    let logos: [ImageDetails]?
    let posters: [ImageDetails]?

    var bestPoster: String? {
        posters?.first { $0.iso6391 == nil }?.filePath
    }

    func bestLogo(language: String = "en") -> String? {
        logos?.first { $0.iso6391 == language }?.filePath ?? logos?.first?.filePath
    }
}

struct ImageDetails: Decodable {
    let iso6391: String?
    let filePath: String?
}

struct WatchProviderResponse: Decodable {
    let id: Int?
    let results: [String: CountryWatchProviders]?
}

struct CountryWatchProviders: Decodable {
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
    let free: [WatchProvider]?
    let ads: [WatchProvider]?

    var all: [WatchProvider] {
        (flatrate ?? []) + (free ?? []) + (ads ?? []) + (rent ?? []) + (buy ?? [])
    }
}

struct WatchProvider: Decodable, Identifiable {
    let providerId: Int?
    let providerName: String?
    let logoPath: String?
    let displayPriority: Int?

    var id: String { "\(providerId ?? 0)-\(providerName ?? "")" }
}
