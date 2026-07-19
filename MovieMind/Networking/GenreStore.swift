//
//  GenreStore.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation

actor GenreStore {

    static let shared = GenreStore()

    private let networkService: NetworkServicing
    private var cached: [Int: String]?
    private var inFlight: Task<[Int: String], Never>?

    init(networkService: NetworkServicing = NetworkManager.shared) {
        self.networkService = networkService
    }

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

    private static func fetchAll(using service: NetworkServicing) async -> [Int: String] {
        async let movie = try? service.fetchGenres(for: .movieGenres)
        async let tv = try? service.fetchGenres(for: .tvGenres)
        let (movieResponse, tvResponse) = await (movie, tv)

        var dictionary: [Int: String] = [:]
        let allGenres = (movieResponse?.genres ?? []) + (tvResponse?.genres ?? [])
        for genre in allGenres {
            if let id = genre.id, let name = genre.name {
                dictionary[id] = name
            }
        }
        return dictionary
    }
}
