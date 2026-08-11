//
//  Endpoints.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

enum ListEndpoint: Endpoint {
    case upcomingMovies
    case nowPlayingMovies
    case trendingMovies
    case trendingTV
    case trendingAll
    case topRatedMovies
    case topRatedTV
    case popularMovies
    case popularTV
    case popularPeople
    case airingTodayTV
    case upcomingTV

    var path: String {
        switch self {
        case .upcomingMovies: return "movie/upcoming"
        case .nowPlayingMovies: return "movie/now_playing"
        case .trendingMovies: return "trending/movie/day"
        case .trendingTV: return "trending/tv/day"
        case .trendingAll: return "trending/all/day"
        case .topRatedMovies: return "movie/top_rated"
        case .topRatedTV: return "tv/top_rated"
        case .popularMovies: return "movie/popular"
        case .popularTV: return "tv/popular"
        case .popularPeople: return "person/popular"
        case .airingTodayTV: return "tv/airing_today"
        case .upcomingTV: return "discover/tv"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .upcomingMovies, .nowPlayingMovies:
            return [URLQueryItem(name: "region", value: Self.regionCode)]
        case .upcomingTV:
            return [
                URLQueryItem(name: "first_air_date.gte", value: Self.todayString),
                URLQueryItem(name: "sort_by", value: "popularity.desc")
            ]
        default:
            return []
        }
    }

    private static var regionCode: String {
        Locale.current.region?.identifier ?? "US"
    }

    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }
}

enum GenreEndpoint: Endpoint {
    case movieGenres
    case tvGenres

    var path: String {
        switch self {
        case .movieGenres: return "genre/movie/list"
        case .tvGenres:    return "genre/tv/list"
        }
    }

    var queryItems: [URLQueryItem] { [] }
}

enum SearchEndpoint: Endpoint {
    case searchMovies(query: String, page: Int = 1)
    case searchTV(query: String, page: Int = 1)
    case searchPeople(query: String, page: Int = 1)
    case searchMulti(query: String, page: Int = 1)

    var path: String {
        switch self {
        case .searchMovies: return "search/movie"
        case .searchTV: return "search/tv"
        case .searchPeople: return "search/person"
        case .searchMulti: return "search/multi"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .searchMovies(let query, let page),
                .searchTV(let query, let page),
                .searchPeople(let query, let page),
                .searchMulti(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "include_adult", value: "true")
            ]
        }
    }
}

enum DetailEndpoint: Endpoint {
    case movieDetails(id: Int)
    case tvDetails(id: Int)
    case peopleDetails(id: Int)

    var path: String {
        switch self {
        case .movieDetails(let id): return "movie/\(id)"
        case .tvDetails(let id): return "tv/\(id)"
        case .peopleDetails(let id): return "person/\(id)"
        }
    }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "append_to_response", value: "credits")]
    }
}

enum ImageEndpoint: Endpoint {
    case movieImages(id: Int)
    case tvImages(id: Int)
    case personImages(id: Int)

    var path: String {
        switch self {
        case .movieImages(let id): return "movie/\(id)/images"
        case .tvImages(let id): return "tv/\(id)/images"
        case .personImages(let id): return "person/\(id)/images"
        }
    }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "include_image_language", value: "en,null")]
    }
}

enum SimilarEndpoint: Endpoint {
    case movieSimilar(id: Int)
    case tvSimilar(id: Int)

    var path: String {
        switch self {
        case .movieSimilar(let id): return "movie/\(id)/similar"
        case .tvSimilar(let id): return "tv/\(id)/similar"
        }
    }

    var queryItems: [URLQueryItem] { [] }
}

enum WatchProviderEndpoint: Endpoint {
    case movieProviders(id: Int)
    case tvProviders(id: Int)

    var path: String {
        switch self {
        case .movieProviders(let id): return "movie/\(id)/watch/providers"
        case .tvProviders(let id): return "tv/\(id)/watch/providers"
        }
    }

    var queryItems: [URLQueryItem] { [] }
}

enum CreditsEndpoint: Endpoint {
    case personCombinedCredits(id: Int)

    var path: String {
        switch self {
        case .personCombinedCredits(let id): return "person/\(id)/combined_credits"
        }
    }

    var queryItems: [URLQueryItem] { [] }
}

enum CollectionEndpoint: Endpoint {
    case details(id: Int)

    var path: String {
        switch self {
        case .details(let id): return "collection/\(id)"
        }
    }

    var queryItems: [URLQueryItem] { [] }
}
