//
//  MediaModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

enum MediaType: String, Codable {
    case movie
    case tv
    case person
}

struct GenreResponse: Decodable {
    let genres: [Genre]?
}

struct Dates: Decodable {
    let minimum: String?
    let maximum: String?
}

struct ListRespond: Decodable {
    let page: Int?
    let results: [MediaItem]?
    let totalPages: Int?
    let totalResults: Int?
    let dates: Dates? // Special to Movies
}

extension ListRespond {

    func stamping(_ mediaType: MediaType) -> ListRespond {
        guard let results else { return self }
        let updated = results.map { item -> MediaItem in
            var copy = item
            copy.mediaType = mediaType
            return copy
        }
        return ListRespond(page: page, results: updated,
                    totalPages: totalPages, totalResults: totalResults,
                    dates: dates)
    }
}

struct MediaItem: Decodable, Identifiable {
    let id: Int?
    var mediaType: MediaType?
    let adult: Bool?
    let popularity: Double?
    let voteAverage: Double?
    let voteCount: Int?
    let overview: String?
    let backdropPath: String?
    let posterPath: String?
    let originalLanguage: String?
    let genreIds: [Int]?
    let name: String? // Special to TV and People

    // Special to Movies
    let title: String?
    let originalTitle: String?
    let releaseDate: String?
    let video: Bool?

    // Special to TVs
    let originalName: String?
    let firstAirDate: String?
    let originCountry: [String]?

    // Special to People
    let gender: Int?
    let knownForDepartment: String?
    let profilePath: String?
    let knownFor: [KnownFor]?

    var displayName: String {
        return title ?? name ?? "Untitled"
    }

    var displayPath: String {
        return posterPath ?? profilePath ?? " -- "
    }

    var displayDate: String? {
        releaseDate ?? firstAirDate
    }
}

struct KnownFor: Decodable {
    let adult: Bool?
    let backdropPath: String?
    let id: Int?
    let name, originalName, overview, posterPath: String?
    let mediaType: MediaType?
    let originalLanguage: String?
    let genreIds: [Int]?
    let popularity: Double?
    let firstAirDate: String?
    let voteAverage: Double?
    let voteCount: Int?
    let originCountry: [String]?
    let title, originalTitle, releaseDate: String?
    let video: Bool?
}
