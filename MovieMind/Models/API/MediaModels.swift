//
//  MediaModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

enum MediaType: String, Codable, Sendable {
    case movie
    case tv
    case person
}

struct GenreResponse: Decodable, Sendable {
    @Fallback var genres: [Genre] = []
}

struct ListRespond: Decodable, Sendable {
    @Fallback var results: [MediaItem] = []
    let page: Int?
    let totalPages: Int?
}

extension ListRespond {

    /// Search and detail endpoints omit `media_type`; the caller knows it, so it stamps it in.
    func stamping(_ mediaType: MediaType) -> ListRespond {
        let stamped = results.map { item in
            var copy = item
            copy.mediaType = mediaType
            return copy
        }
        return ListRespond(results: stamped, page: page, totalPages: totalPages)
    }
}

/// A row in any list: movie, show or person.
///
/// `title`/`releaseDate` belong to movies and `name`/`firstAirDate` to TV and
/// people, so neither pair is "missing data" — read them through `displayName`
/// and `displayDate` instead. A nil `id` means the row is unusable and every
/// consumer drops it.
struct MediaItem: Decodable, Identifiable, Sendable {
    let id: Int?
    @Fallback var popularity: Double = 0
    @Fallback var voteAverage: Double = 0
    @Fallback var adult: Bool = false
    @Fallback var genreIds: [Int] = []
    @Fallback var knownFor: [KnownFor] = []
    let title: String?
    let name: String?
    let releaseDate: String?
    let firstAirDate: String?
    let posterPath: String?
    let profilePath: String?
    let knownForDepartment: String?
    var mediaType: MediaType?

    init(id: Int?,
         mediaType: MediaType? = nil,
         adult: Bool = false,
         popularity: Double = 0,
         voteAverage: Double = 0,
         posterPath: String? = nil,
         genreIds: [Int] = [],
         name: String? = nil,
         title: String? = nil,
         releaseDate: String? = nil,
         firstAirDate: String? = nil,
         knownForDepartment: String? = nil,
         profilePath: String? = nil,
         knownFor: [KnownFor] = []) {
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
    var displayPath: String { posterPath ?? profilePath ?? "" }
    var displayDate: String? { releaseDate ?? firstAirDate }
}

struct KnownFor: Decodable, Sendable {
    let name: String?
    let title: String?

    var displayName: String { title ?? name ?? "" }
}
