//
//  DateExtensions.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

extension Date {

    func relativeReleaseString() -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "Releases today"
        }

        let isThisWeek = calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear)
        let isThisYear = calendar.isDate(self, equalTo: now, toGranularity: .year)

        let formatter = Self.releaseFormatter
        if isThisWeek {
            formatter.dateFormat = "EEEE"
        } else if isThisYear {
            formatter.dateFormat = "MMMM d"
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
        }

        let prefix = self < now ? "Released on" : "Releases on"
        return "\(prefix) \(formatter.string(from: self))"
    }

    private static let releaseFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}

extension String {

    func toDate() -> Date? {
        Self.tmdbFormatter.date(from: self)
    }

    private static let tmdbFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
