//
//  AccessibilityTextTests.swift
//  MovieMindTests
//
//  Created by Semih Söğüt on 18.08.2026.
//

import Testing
@testable import MovieMind

@Suite("VoiceOver labels")
struct AccessibilityTextTests {

    @Test("A movie reads name, kind, year and rating")
    func movieLabel() {
        let item = MediaItem(id: 1, mediaType: .movie, voteAverage: 8.234,
                             title: "Dune", releaseDate: "2024-03-01")
        #expect(item.accessibilityLabel == "Dune, Movie, 2024, rated 8.2 out of 10")
    }

    @Test("A person reads the department instead of a year")
    func personLabel() {
        let item = MediaItem(id: 2, mediaType: .person, name: "Zendaya",
                             knownForDepartment: "Acting")
        #expect(item.accessibilityLabel == "Zendaya, Person, Acting")
    }

    @Test("A missing rating is left out rather than read as zero")
    func noRating() {
        let item = MediaItem(id: 3, mediaType: .tv, name: "Severance")
        #expect(item.accessibilityLabel == "Severance, TV series")
    }

    @Test("A movie and a show with the same id get different identities")
    func uniqueIdSeparatesMediaTypes() {
        let movie = MediaItem(id: 42, mediaType: .movie, title: "A")
        let show = MediaItem(id: 42, mediaType: .tv, name: "B")
        #expect(movie.uniqueId != show.uniqueId)
    }
}
