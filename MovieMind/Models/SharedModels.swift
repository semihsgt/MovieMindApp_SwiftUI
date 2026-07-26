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

struct ProductionCompany: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let originCountry: String?
    let logoPath: String?
}

struct ProductionCountry: Decodable {
    let iso31661: String?
    let name: String?
}

struct SpokenLanguage: Decodable {
    let iso6391: String?
    let name: String?
    let englishName: String?
}

struct Images: Decodable, Identifiable {
    let id: Int?
    let backdrops: [ImageDetails]?
    let logos: [ImageDetails]?
    let posters: [ImageDetails]?
    let profiles: [ImageDetails]?
}

struct ImageDetails: Decodable {
    let iso31661: String?
    let iso6391: String?
    let width: Int?
    let height: Int?
    let aspectRatio: Double?
    let voteAverage: Double?
    let voteCount: Int?
    let filePath: String?
}

extension Images {

    var bestPoster: String? {
        posters?.first(where: { $0.iso6391 == nil })?.filePath
    }

    func bestLogo(language: String = "en") -> String? {
        logos?.first(where: { $0.iso6391 == language })?.filePath
        ?? logos?.first?.filePath
    }
}

// https://api.themoviedb.org/3/{media_type}/{id}/watch/providers

struct WatchProviderResponse: Decodable {
    let id: Int?
    let results: [String: CountryWatchProviders]?
}

struct CountryWatchProviders: Decodable {
    let link: String?
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
    let free: [WatchProvider]?
    let ads: [WatchProvider]?
}

struct WatchProvider: Decodable, Identifiable {
    let providerId: Int?
    let providerName: String?
    let logoPath: String?
    let displayPriority: Int?

    var id: String { "\(providerId ?? 0)-\(providerName ?? "")" }
}
