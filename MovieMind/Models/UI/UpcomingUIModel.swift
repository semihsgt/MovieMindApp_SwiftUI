//
//  UpcomingUIModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

struct UpcomingUIModel: Identifiable {
    let id: Int
    let mediaType: MediaType
    let result: MediaItem
    let genreNames: [String]
}

enum UpcomingUIModelMapper {

    /// Maps the raw list items and returns them ordered by release date.
    static func map(_ items: [MediaItem], genres: [Int: String]) -> [UpcomingUIModel] {
        items
            .compactMap { item in
                guard let id = item.id else { return nil }
                return UpcomingUIModel(id: id,
                                       mediaType: item.mediaType ?? .movie,
                                       result: item,
                                       genreNames: (item.genreIds ?? []).compactMap { genres[$0] })
            }
            .sorted { first, second in
                guard let a = first.result.displayDate, !a.isEmpty else { return false }
                guard let b = second.result.displayDate, !b.isEmpty else { return true }
                return a < b
            }
    }
}
