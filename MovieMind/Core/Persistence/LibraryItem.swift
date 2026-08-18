//
//  LibraryItem.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation
import SwiftData

/// One saved title.
///
/// `displayName` and `posterPath` are a copy of what TMDB returned at save time,
/// not a reference: the library list renders straight from the store, so it works
/// offline and without one request per row. The trade is that a title renamed on
/// TMDB keeps its old text here until it is re-saved.
@Model
final class LibraryItem {

    @Attribute(.unique) var key: String

    var mediaId: Int
    var mediaTypeRaw: String
    var displayName: String
    var posterPath: String?
    var dateAdded: Date

    var mediaType: MediaType {
        MediaType(rawValue: mediaTypeRaw) ?? .movie
    }

    init(mediaId: Int, mediaType: MediaType, displayName: String, posterPath: String?) {
        self.key = Self.key(id: mediaId, mediaType: mediaType)
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.displayName = displayName
        self.posterPath = posterPath
        self.dateAdded = .now
    }

    /// Identity across both id and type, since a movie and a show can share an id.
    static func key(id: Int, mediaType: MediaType) -> String {
        "\(mediaType.rawValue)-\(id)"
    }
}
