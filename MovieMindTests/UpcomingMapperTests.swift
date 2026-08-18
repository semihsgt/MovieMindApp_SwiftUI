//
//  UpcomingMapperTests.swift
//  MovieMindTests
//
//  Created by Semih Söğüt on 18.08.2026.
//

import Testing
@testable import MovieMind

@Suite("UpcomingUIModelMapper")
struct UpcomingMapperTests {

    @Test("Rows without an id are dropped")
    func dropsIdlessRows() {
        let items = [MediaItem(id: nil, mediaType: .movie, title: "Ghost"),
                     MediaItem(id: 1, mediaType: .movie, title: "Real")]
        let mapped = UpcomingUIModelMapper.map(items, genres: [:])
        #expect(mapped.count == 1)
        #expect(mapped.first?.result.displayName == "Real")
    }

    @Test("Genre ids become names and unknown ids are skipped")
    func mapsGenreNames() {
        let item = MediaItem(id: 1, mediaType: .movie, genreIds: [28, 999], title: "X")
        let mapped = UpcomingUIModelMapper.map([item], genres: [28: "Action"])
        #expect(mapped.first?.genreNames == ["Action"])
    }

    @Test("Sorted by date, undated last")
    func sortsByDate() {
        let items = [
            MediaItem(id: 1, mediaType: .movie, title: "Later", releaseDate: "2026-12-01"),
            MediaItem(id: 2, mediaType: .movie, title: "Undated"),
            MediaItem(id: 3, mediaType: .movie, title: "Sooner", releaseDate: "2026-01-01")
        ]
        let names = UpcomingUIModelMapper.map(items, genres: [:]).map(\.result.displayName)
        #expect(names == ["Sooner", "Later", "Undated"])
    }
}
