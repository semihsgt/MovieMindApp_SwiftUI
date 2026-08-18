//
//  String+Date.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

extension String {

    /// Parses TMDB's "yyyy-MM-dd" date strings.
    func toDate() -> Date? {
        Self.tmdbFormatter.date(from: self)
    }

    /// The leading year of a TMDB date string, or nil when there isn't one.
    var releaseYear: String? {
        let year = prefix(4)
        return year.isEmpty ? nil : String(year)
    }

    private static let tmdbFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
