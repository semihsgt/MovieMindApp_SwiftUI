//
//  DetailModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

struct MovieDetail: Decodable, Identifiable {
    let id: Int?
    let title: String?
    let adult: Bool?
    let status: String?
    let tagline: String?
    let overview: String?
    let releaseDate: String?
    let runtime: Int?
    let popularity: Double?
    let voteAverage: Double?
    let posterPath: String?
    let belongsToCollection: BelongsToCollection?
    let genres: [Genre]?
    let credits: Credits?
}

struct TVDetail: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let adult: Bool?
    let status: String?
    let tagline: String?
    let overview: String?
    let firstAirDate: String?
    let numberOfSeasons: Int?
    let popularity: Double?
    let voteAverage: Double?
    let posterPath: String?
    let lastEpisodeToAir: TEpisodeToAir?
    let nextEpisodeToAir: TEpisodeToAir?
    let seasons: [Season]?
    let createdBy: [CreatedBy]?
    let genres: [Genre]?
    let credits: Credits?
}

struct PersonDetail: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let adult: Bool?
    let biography: String?
    let knownForDepartment: String?
    let popularity: Double?
    let profilePath: String?
}

struct BelongsToCollection: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let backdropPath: String?
}

struct CollectionDetail: Decodable {
    let id: Int?
    let name: String?
    let overview: String?
    let backdropPath: String?
    let parts: [MediaItem]?
}

struct CreatedBy: Decodable, Identifiable {
    let id: Int?
    let name: String?
}

struct TEpisodeToAir: Decodable, Identifiable {
    let id: Int?
    let seasonNumber: Int?
    let episodeNumber: Int?
    let name: String?
    let airDate: String?
    let stillPath: String?
}

struct Season: Decodable, Identifiable {
    let id: Int?
    let seasonNumber: Int?
    let name: String?
    let episodeCount: Int?
    let posterPath: String?
}
