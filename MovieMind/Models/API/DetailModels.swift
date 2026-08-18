//
//  DetailModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

// Property order is the same in every model: id, the fields TMDB always sends
// (non-optional via `@Fallback`), then the ones whose absence the UI reacts to.

struct MovieDetail: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var title: String = ""
    @Fallback var tagline: String = ""
    @Fallback var overview: String = ""
    @Fallback var status: String = ""
    @Fallback var runtime: Int = 0
    @Fallback var popularity: Double = 0
    @Fallback var voteAverage: Double = 0
    @Fallback var adult: Bool = false
    @Fallback var genres: [Genre] = []
    let posterPath: String?
    let releaseDate: String?
    let belongsToCollection: BelongsToCollection?
    let credits: Credits?
}

struct TVDetail: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    @Fallback var tagline: String = ""
    @Fallback var overview: String = ""
    @Fallback var status: String = ""
    @Fallback var numberOfSeasons: Int = 0
    @Fallback var popularity: Double = 0
    @Fallback var voteAverage: Double = 0
    @Fallback var adult: Bool = false
    @Fallback var genres: [Genre] = []
    @Fallback var seasons: [Season] = []
    @Fallback var createdBy: [CreatedBy] = []
    let posterPath: String?
    let firstAirDate: String?
    let lastEpisodeToAir: TEpisodeToAir?
    let nextEpisodeToAir: TEpisodeToAir?
    let credits: Credits?
}

struct PersonDetail: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    @Fallback var biography: String = ""
    @Fallback var popularity: Double = 0
    @Fallback var adult: Bool = false
    let profilePath: String?
    let knownForDepartment: String?
}

struct BelongsToCollection: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    let backdropPath: String?

    var displayName: String { name.isEmpty ? "Collection" : name }
}

struct CollectionDetail: Decodable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    @Fallback var overview: String = ""
    @Fallback var parts: [MediaItem] = []
    let backdropPath: String?
}

struct CreatedBy: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
}

struct TEpisodeToAir: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    @Fallback var seasonNumber: Int = 0
    @Fallback var episodeNumber: Int = 0
    let airDate: String?
    let stillPath: String?

    var displayName: String { name.isEmpty ? "Untitled" : name }
    var hasNumbering: Bool { seasonNumber > 0 && episodeNumber > 0 }
}

struct Season: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    @Fallback var seasonNumber: Int = 0
    @Fallback var episodeCount: Int = 0
    let posterPath: String?

    var displayName: String { name.isEmpty ? "Season \(seasonNumber)" : name }
}
