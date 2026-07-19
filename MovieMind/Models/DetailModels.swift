//
//  DetailModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

struct MovieDetail: Decodable, Identifiable {
    let id: Int?
    let imdbId: String?
    let title: String?
    let originalTitle: String?
    let adult: Bool?
    let video: Bool?
    let status: String?
    let tagline: String?
    let overview: String?
    let releaseDate: String?
    let runtime: Int?
    let originalLanguage: String?
    let popularity: Double?
    let voteAverage: Double?
    let voteCount: Int?
    let budget: Int?
    let revenue: Int?
    let homepage: String?
    let backdropPath: String?
    let posterPath: String?
    let belongsToCollection: BelongsToCollection?
    let genres: [Genre]?
    let originCountry: [String]?
    let spokenLanguages: [SpokenLanguage]?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let credits: Credits?
}

struct BelongsToCollection: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let posterPath: String?
    let backdropPath: String?
}

struct TVDetail: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let originalName: String?
    let type: String?
    let adult: Bool?
    let status: String?
    let inProduction: Bool?
    let tagline: String?
    let overview: String?
    let originalLanguage: String?
    let firstAirDate: String?
    let lastAirDate: String?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let episodeRunTime: [Int]?
    let popularity: Double?
    let voteAverage: Double?
    let voteCount: Int?
    let homepage: String?
    let backdropPath: String?
    let posterPath: String?
    let lastEpisodeToAir: TEpisodeToAir?
    let nextEpisodeToAir: TEpisodeToAir?
    let seasons: [Season]?
    let createdBy: [CreatedBy]?
    let networks: [Network]?
    let genres: [Genre]?
    let languages: [String]?
    let originCountry: [String]?
    let spokenLanguages: [SpokenLanguage]?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let credits: Credits?
}

struct CreatedBy: Decodable, Identifiable {
    let id: Int?
    let creditId: String?
    let name: String?
    let originalName: String?
    let gender: Int?
    let profilePath: String?
}

struct TEpisodeToAir: Decodable, Identifiable {
    let id: Int?
    let showId: Int?
    let seasonNumber: Int?
    let episodeNumber: Int?
    let name: String?
    let overview: String?
    let airDate: String?
    let episodeType: String?
    let productionCode: String?
    let runtime: Int?
    let voteAverage: Double?
    let voteCount: Int?
    let stillPath: String?
}

struct Network: Decodable, Identifiable {
    let id: Int?
    let name: String?
    let originCountry: String?
    let logoPath: String?
}

struct Season: Decodable, Identifiable {
    let id: Int?
    let seasonNumber: Int?
    let name: String?
    let overview: String?
    let airDate: String?
    let episodeCount: Int?
    let voteAverage: Double?
    let posterPath: String?
}

struct PersonDetail: Decodable, Identifiable {
    let id: Int?
    let imdbId: String?
    let name: String?
    let gender: Int?
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let knownForDepartment: String?
    let alsoKnownAs: [String]?
    let popularity: Double?
    let profilePath: String?
    let homepage: String?
    let adult: Bool?
}

struct CollectionDetail: Decodable {
    let id: Int?
    let name: String?
    let overview: String?
    let backdropPath: String?
    let parts: [MediaItem]?
}
