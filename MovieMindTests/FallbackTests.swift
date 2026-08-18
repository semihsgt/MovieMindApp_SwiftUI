//
//  FallbackTests.swift
//  MovieMindTests
//
//  Created by Semih Söğüt on 18.08.2026.
//

import Testing
import Foundation
@testable import MovieMind

@Suite("Fallback decoding")
struct FallbackTests {

    private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: Data(json.utf8))
    }

    @Test("A missing key falls back to the empty value")
    func missingKey() throws {
        let movie = try decode(MovieDetail.self, from: #"{"id": 1}"#)
        #expect(movie.runtime == 0)
        #expect(movie.title == "")
        #expect(movie.genres.isEmpty)
    }

    @Test("An explicit null falls back too")
    func explicitNull() throws {
        let movie = try decode(MovieDetail.self, from: #"{"id": 1, "runtime": null, "title": null}"#)
        #expect(movie.runtime == 0)
        #expect(movie.title == "")
    }

    @Test("A wrong type falls back instead of failing the whole response")
    func wrongType() throws {
        let movie = try decode(MovieDetail.self, from: #"{"id": 1, "runtime": "142"}"#)
        #expect(movie.runtime == 0)
    }

    @Test("A real value survives")
    func realValue() throws {
        let movie = try decode(MovieDetail.self, from: #"{"id": 1, "runtime": 142, "title": "Dune"}"#)
        #expect(movie.runtime == 142)
        #expect(movie.title == "Dune")
    }

    @Test("Optional fields stay optional")
    func optionalsUntouched() throws {
        let movie = try decode(MovieDetail.self, from: #"{"id": 1}"#)
        #expect(movie.posterPath == nil)
        #expect(movie.releaseDate == nil)
    }
}
