//
//  NetworkServices.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

// Narrow, per-screen contracts instead of one shared "everything" protocol,
// so a caller only sees the calls it actually makes and a test only mocks those.

protocol ListServicing: Sendable {
    func fetchList(for endpoint: ListEndpoint) async throws -> ListRespond
}

protocol SearchServicing: Sendable {
    func fetchSearch(for endpoint: SearchEndpoint) async throws -> ListRespond
}

protocol GenreServicing: Sendable {
    func fetchGenres(for endpoint: GenreEndpoint) async throws -> GenreResponse
}

protocol MediaImageServicing: Sendable {
    func fetchImages(id: Int, for mediaType: MediaType) async throws -> Images
}

protocol DetailServicing: Sendable {
    func fetchDetails<T: Decodable>(id: Int, for mediaType: MediaType) async throws -> T
    func fetchSimilar(id: Int, for mediaType: MediaType) async throws -> ListRespond
    func fetchWatchProviders(id: Int, for mediaType: MediaType) async throws -> WatchProviderResponse
    func fetchPersonCredits(id: Int) async throws -> CombinedCredits
}

protocol CollectionServicing: Sendable {
    func fetchCollection(id: Int) async throws -> CollectionDetail
}
