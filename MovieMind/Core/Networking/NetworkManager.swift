//
//  NetworkManager.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case missingKey
    case unauthorized
    case notFound
    case rateLimited
    case invalidURL
    case invalidResponse
    case incompleteData
    case decodingError(Error)
    case unsupportedMediaType

    var errorDescription: String? {
        switch self {
        case .missingKey: "TMDB API key is not configured. Copy SecretsExample.xcconfig as Secrets.xcconfig and add your key."
        case .unauthorized: "TMDB rejected the API key. Check the TMDB_API_KEY value in Secrets.xcconfig."
        case .notFound: "This title is no longer available on TMDB."
        case .rateLimited: "Too many requests to TMDB. Please try again in a moment."
        case .invalidURL: "Invalid URL address."
        case .invalidResponse: "An invalid response was received from the server."
        case .incompleteData: "Details could not be loaded."
        case .decodingError(let error): "Data decoding error: \(error.localizedDescription)"
        case .unsupportedMediaType: "This content type does not support the requested resource."
        }
    }
}

/// Every TMDB request funnels through this actor: one place that holds the key,
/// builds the URL, maps status codes to `NetworkError` and decodes the response.
/// Callers depend on the narrow protocols above it, never on the actor itself.
actor NetworkManager: ListServicing, SearchServicing, GenreServicing,
                      MediaImageServicing, DetailServicing, CollectionServicing {

    static let shared = NetworkManager()
    private init() {}

    private let baseURL = "https://api.themoviedb.org/3"

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private func buildURL(for endpoint: Endpoint, apiKey: String) -> URL? {
        guard var components = URLComponents(string: "\(baseURL)/\(endpoint.path)") else { return nil }

        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        queryItems.append(contentsOf: endpoint.queryItems)

        components.queryItems = queryItems
        return components.url
    }

    private func performCall<T: Decodable>(for endpoint: Endpoint) async throws -> T {
        guard let apiKey = Secrets.apiKey else {
            throw NetworkError.missingKey
        }

        guard let url = buildURL(for: endpoint, apiKey: apiKey) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299: break
        case 401, 403:  throw NetworkError.unauthorized
        case 404:       throw NetworkError.notFound
        case 429:       throw NetworkError.rateLimited
        default:        throw NetworkError.invalidResponse
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func fetchList(for endpoint: ListEndpoint) async throws -> ListRespond {
        try await performCall(for: endpoint)
    }

    func fetchGenres(for endpoint: GenreEndpoint) async throws -> GenreResponse {
        try await performCall(for: endpoint)
    }

    func fetchSearch(for endpoint: SearchEndpoint) async throws -> ListRespond {
        try await performCall(for: endpoint)
    }

    func fetchDetails<T: Decodable & Sendable>(id: Int, for mediaType: MediaType) async throws -> T {
        try await performCall(for: MediaEndpoint.details(mediaType, id: id))
    }

    func fetchImages(id: Int, for mediaType: MediaType) async throws -> Images {
        try await performCall(for: MediaEndpoint.images(mediaType, id: id))
    }

    func fetchSimilar(id: Int, for mediaType: MediaType) async throws -> ListRespond {
        guard mediaType != .person else { throw NetworkError.unsupportedMediaType }
        return try await performCall(for: MediaEndpoint.similar(mediaType, id: id))
    }

    func fetchWatchProviders(id: Int, for mediaType: MediaType) async throws -> WatchProviderResponse {
        guard mediaType != .person else { throw NetworkError.unsupportedMediaType }
        return try await performCall(for: MediaEndpoint.watchProviders(mediaType, id: id))
    }

    func fetchPersonCredits(id: Int) async throws -> CombinedCredits {
        try await performCall(for: CreditsEndpoint.personCombinedCredits(id: id))
    }

    func fetchCollection(id: Int) async throws -> CollectionDetail {
        try await performCall(for: CollectionEndpoint.details(id: id))
    }
}
