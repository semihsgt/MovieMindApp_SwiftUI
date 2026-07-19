//
//  NetworkManager.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

protocol NetworkServicing: Sendable {
    func fetchList(for endpoint: ListEndpoint) async throws -> ListRespond
    func fetchGenres(for endpoint: GenreEndpoint) async throws -> GenreResponse
    func fetchSearch(for endpoint: SearchEndpoint) async throws -> ListRespond
    func fetchDetails<T: Decodable>(id: Int, for mediaType: MediaType) async throws -> T
    func fetchImages(id: Int, for mediaType: MediaType) async throws -> Images
    func fetchSimilar(id: Int, for mediaType: MediaType) async throws -> ListRespond
    func fetchWatchProviders(id: Int, for mediaType: MediaType) async throws -> WatchProviderResponse
    func fetchPersonCredits(id: Int) async throws -> CombinedCredits
    func fetchCollection(id: Int) async throws -> CollectionDetail
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case unsupportedMediaType

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL address."
        case .invalidResponse: return "An invalid response was received from the server."
        case .decodingError(let error): return "Data decoding error: \(error.localizedDescription)"
        case .unsupportedMediaType: return "This content type does not support the requested resource."
        }
    }
}

actor NetworkManager: NetworkServicing {

    static let shared = NetworkManager()
    private init() {}

    private let baseURL = "https://api.themoviedb.org/3"

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private func buildURL(for endpoint: Endpoint) -> URL? {
        guard var components = URLComponents(string: "\(baseURL)/\(endpoint.path)") else { return nil }

        var queryItems = [URLQueryItem(name: "api_key", value: Secrets.apiKey)]
        queryItems.append(contentsOf: endpoint.queryItems)

        components.queryItems = queryItems
        return components.url
    }

    private func performCall<T: Decodable>(for endpoint: Endpoint) async throws -> T {
        guard let url = buildURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
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

    func fetchDetails<T: Decodable>(id: Int, for mediaType: MediaType) async throws -> T {
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

enum TMDBImage {

    enum Size: String {
        case w200
        case w500
        case w780
        case original
    }

    static func url(for path: String?, size: Size = .w500) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)\(path)")
    }
}

enum ImagePrefetcher {
    static func prefetch(_ urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in Set(urls) {
                group.addTask {
                    _ = try? await URLSession.shared.data(from: url)
                }
            }
        }
    }
}
