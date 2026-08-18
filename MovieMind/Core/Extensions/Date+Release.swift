//
//  Date+Release.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

extension Date {

    func relativeReleaseString() -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) { return "Releases today" }

        let locale = Locale(identifier: "en_US")
        let formatted: String

        if calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) {
            formatted = self.formatted(.dateTime.locale(locale).weekday(.wide))
        } else if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            formatted = self.formatted(.dateTime.locale(locale).month(.wide).day())
        } else {
            formatted = self.formatted(.dateTime.locale(locale).month(.wide).day().year())
        }

        return "\(self < now ? "Released on" : "Releases on") \(formatted)"
    }
}
