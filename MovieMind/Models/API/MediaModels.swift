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

struct ListRespond: Decodable {
    let page: Int?
    let results: [MediaItem]?
    let totalPages: Int?
}

extension ListRespond {

    func stamping(_ mediaType: MediaType) -> ListRespond {
        guard let results else { return self }
        let stamped = results.map { item in
            var copy = item
            copy.mediaType = mediaType
            return copy
        }
        return ListRespond(page: page, results: stamped, totalPages: totalPages)
    }
}

struct MediaItem: Decodable, Identifiable {
    let id: Int?
    var mediaType: MediaType?
    let adult: Bool?
    let popularity: Double?
    let voteAverage: Double?
    let posterPath: String?
    let genreIds: [Int]?
    let name: String?
    let title: String?
    let releaseDate: String?
    let firstAirDate: String?
    let knownForDepartment: String?
    let profilePath: String?
    let knownFor: [KnownFor]?

    init(id: Int?,
         mediaType: MediaType? = nil,
         adult: Bool? = nil,
         popularity: Double? = nil,
         voteAverage: Double? = nil,
         posterPath: String? = nil,
         genreIds: [Int]? = nil,
         name: String? = nil,
         title: String? = nil,
         releaseDate: String? = nil,
         firstAirDate: String? = nil,
         knownForDepartment: String? = nil,
         profilePath: String? = nil,
         knownFor: [KnownFor]? = nil) {
        self.id = id
        self.mediaType = mediaType
        self.adult = adult
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.posterPath = posterPath
        self.genreIds = genreIds
        self.name = name
        self.title = title
        self.releaseDate = releaseDate
        self.firstAirDate = firstAirDate
        self.knownForDepartment = knownForDepartment
        self.profilePath = profilePath
        self.knownFor = knownFor
    }

    var displayName: String { title ?? name ?? "Untitled" }
    var displayPath: String { posterPath ?? profilePath ?? " -- " }
    var displayDate: String? { releaseDate ?? firstAirDate }
}

struct KnownFor: Decodable {
    let name: String?
    let title: String?
}
