//
//  WatchlistItem.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation
import SwiftData

@Model
final class WatchlistItem {

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

    static func key(id: Int, mediaType: MediaType) -> String {
        "\(mediaType.rawValue)-\(id)"
    }
}
