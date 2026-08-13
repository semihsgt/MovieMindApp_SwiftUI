//
//  GenreStore.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation

protocol GenreProviding: Sendable {
    func genreDictionary() async -> [Int: String]
}

actor GenreStore: GenreProviding {

    static let shared = GenreStore()

    private let networkService: GenreServicing
    private var cached: [Int: String]?
    private var inFlight: Task<[Int: String], Never>?

    init(networkService: GenreServicing = NetworkManager.shared) {
        self.networkService = networkService
    }

    /// Genre id to name, fetched once per launch.
    ///
    /// Callers that arrive while a fetch is in flight await the same task instead of
    /// starting their own. A failed fetch is not cached, so the next caller retries.
    func genreDictionary() async -> [Int: String] {
        if let cached { return cached }
        if let inFlight { return await inFlight.value }

        let task = Task { [networkService] in
            await Self.fetchAll(using: networkService)
        }
        inFlight = task

        let result = await task.value
        inFlight = nil

        if !result.isEmpty { cached = result }
        return result
    }

    private static func fetchAll(using service: GenreServicing) async -> [Int: String] {
        async let movie = try? service.fetchGenres(for: .movieGenres)
        async let tv = try? service.fetchGenres(for: .tvGenres)
        let (movieResponse, tvResponse) = await (movie, tv)

        let genres = (movieResponse?.genres ?? []) + (tvResponse?.genres ?? [])
        return genres.reduce(into: [Int: String]()) { dictionary, genre in
            if let id = genre.id, !genre.name.isEmpty { dictionary[id] = genre.name }
        }
    }
}
