//
//  MediaRoute.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation

struct MediaRoute: Hashable {
    let id: Int
    let mediaType: MediaType

    init?(item: MediaItem) {
        guard let id = item.id else { return nil }
        self.id = id
        self.mediaType = item.mediaType ?? .movie
    }

    init(id: Int, mediaType: MediaType) {
        self.id = id
        self.mediaType = mediaType
    }
}

enum LibraryRoute: Hashable {
    case all
    case category(MediaType)

    var title: String {
        switch self {
        case .all: return "All Saved"
        case .category(.movie): return "Movies"
        case .category(.tv): return "TV Shows"
        case .category(.person): return "People"
        }
    }

    var filter: MediaType? {
        if case .category(let type) = self { return type }
        return nil
    }
}

struct CollectionRoute: Hashable {
    let id: Int
    let name: String
}
