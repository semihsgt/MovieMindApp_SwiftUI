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
        case .missingKey: return "TMDB API key is not configured. Copy SecretsExample.xcconfig as Secrets.xcconfig and add your key."
        case .unauthorized: return "TMDB rejected the API key. Check the TMDB_API_KEY value in Secrets.xcconfig."
        case .notFound: return "This title is no longer available on TMDB."
        case .rateLimited: return "Too many requests to TMDB. Please try again in a moment."
        case .invalidURL: return "Invalid URL address."
        case .invalidResponse: return "An invalid response was received from the server."
        case .incompleteData: return "Details could not be loaded."
        case .decodingError(let error): return "Data decoding error: \(error.localizedDescription)"
        case .unsupportedMediaType: return "This content type does not support the requested resource."
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
        let endpoint: DetailEndpoint
        switch mediaType {
        case .movie:  endpoint = .movieDetails(id: id)
        case .tv:     endpoint = .tvDetails(id: id)
        case .person: endpoint = .peopleDetails(id: id)
        }
        return try await performCall(for: endpoint)
    }

    func fetchImages(id: Int, for mediaType: MediaType) async throws -> Images {
        let endpoint: ImageEndpoint
        switch mediaType {
        case .movie:  endpoint = .movieImages(id: id)
        case .tv:     endpoint = .tvImages(id: id)
        case .person: endpoint = .personImages(id: id)
        }
        return try await performCall(for: endpoint)
    }

    func fetchSimilar(id: Int, for mediaType: MediaType) async throws -> ListRespond {
        let endpoint: SimilarEndpoint
        switch mediaType {
        case .movie:  endpoint = .movieSimilar(id: id)
        case .tv:     endpoint = .tvSimilar(id: id)
        case .person: throw NetworkError.unsupportedMediaType
        }
        return try await performCall(for: endpoint)
    }

    func fetchWatchProviders(id: Int, for mediaType: MediaType) async throws -> WatchProviderResponse {
        let endpoint: WatchProviderEndpoint
        switch mediaType {
        case .movie:  endpoint = .movieProviders(id: id)
        case .tv:     endpoint = .tvProviders(id: id)
        case .person: throw NetworkError.unsupportedMediaType
        }
        return try await performCall(for: endpoint)
    }

    func fetchPersonCredits(id: Int) async throws -> CombinedCredits {
        try await performCall(for: CreditsEndpoint.personCombinedCredits(id: id))
    }

    func fetchCollection(id: Int) async throws -> CollectionDetail {
        try await performCall(for: CollectionEndpoint.details(id: id))
    }
}
