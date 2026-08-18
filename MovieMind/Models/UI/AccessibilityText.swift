//
//  AccessibilityText.swift
//  MovieMind
//
//  Created by Semih Söğüt on 17.08.2026.
//

import Foundation

enum AccessibilityHint {

    /// Only the first item of a rail carries this, so it is said once per row.
    static let horizontalRail = "Swipe left or right with one finger for more"

    /// The hero carousel is paged, so it takes the three-finger gesture.
    static let pagedCarousel = "Swipe left or right with three fingers for another title"
}

extension MediaType {
    /// "TV" reads as the two letters, "TV series" reads as words.
    var spokenName: String {
        switch self {
        case .movie:  "Movie"
        case .tv:     "TV series"
        case .person: "Person"
        }
    }
}

extension MediaItem {

    /// "Dune: Part Two, Movie, 2024, rated 8.2 out of 10".
    var accessibilityLabel: String {
        var parts = [displayName]

        if let mediaType {
            parts.append(mediaType.spokenName)
        }

        if mediaType == .person {
            if let department = knownForDepartment, !department.isEmpty {
                parts.append(department)
            }
        } else {
            if let year = displayDate?.releaseYear {
                parts.append(year)
            }
            if voteAverage > 0 {
                parts.append(String(format: "rated %.1f out of 10", voteAverage))
            }
        }

        return parts.joined(separator: ", ")
    }
}

extension UpcomingUIModel {

    /// "Dune: Part Two, Movie, Science Fiction, Adventure, Releases on March 1".
    var accessibilityLabel: String {
        ([result.displayName, mediaType.spokenName]
         + Array(genreNames.prefix(2))
         + [result.displayDate?.toDate()?.relativeReleaseString() ?? "Release date unknown"])
            .joined(separator: ", ")
    }
}
