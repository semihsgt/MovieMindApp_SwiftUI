//
//  Endpoints.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

/// One TMDB call, described as data. The API key and base URL are added by
/// `NetworkManager`, so a new call is just another case with a path and,
/// where needed, its query items.
protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    /// Most calls need nothing beyond the API key, which NetworkManager adds.
    var queryItems: [URLQueryItem] { [] }
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
        case .upcomingMovies: "movie/upcoming"
        case .nowPlayingMovies: "movie/now_playing"
        case .trendingMovies: "trending/movie/day"
        case .trendingTV: "trending/tv/day"
        case .trendingAll: "trending/all/day"
        case .topRatedMovies: "movie/top_rated"
        case .topRatedTV: "tv/top_rated"
        case .popularMovies: "movie/popular"
        case .popularTV: "tv/popular"
        case .popularPeople: "person/popular"
        case .airingTodayTV: "tv/airing_today"
        case .upcomingTV: "discover/tv"
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

    /// Without a fixed locale the formatter follows the device's calendar, so a
    /// Buddhist or Japanese one would send a year TMDB can't match and the
    /// upcoming filter would come back empty.
    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: .now)
    }
}

enum GenreEndpoint: Endpoint {
    case movieGenres
    case tvGenres

    var path: String {
        switch self {
        case .movieGenres: "genre/movie/list"
        case .tvGenres: "genre/tv/list"
        }
    }
}

enum SearchEndpoint: Endpoint {
    case searchMovies(query: String, page: Int = 1)
    case searchTV(query: String, page: Int = 1)
    case searchPeople(query: String, page: Int = 1)
    case searchMulti(query: String, page: Int = 1)

    var path: String {
        switch self {
        case .searchMovies: "search/movie"
        case .searchTV: "search/tv"
        case .searchPeople: "search/person"
        case .searchMulti: "search/multi"
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

/// The four calls that only differ by media type and suffix.
/// `MediaType.rawValue` is already TMDB's path segment: movie, tv, person.
enum MediaEndpoint: Endpoint {
    case details(MediaType, id: Int)
    case images(MediaType, id: Int)
    case similar(MediaType, id: Int)
    case watchProviders(MediaType, id: Int)

    var path: String {
        switch self {
        case .details(let type, let id):        "\(type.rawValue)/\(id)"
        case .images(let type, let id):         "\(type.rawValue)/\(id)/images"
        case .similar(let type, let id):        "\(type.rawValue)/\(id)/similar"
        case .watchProviders(let type, let id): "\(type.rawValue)/\(id)/watch/providers"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .details: [URLQueryItem(name: "append_to_response", value: "credits")]
        case .images:  [URLQueryItem(name: "include_image_language", value: "en,null")]
        default:       []
        }
    }
}

enum CreditsEndpoint: Endpoint {
    case personCombinedCredits(id: Int)

    var path: String {
        switch self {
        case .personCombinedCredits(let id): "person/\(id)/combined_credits"
        }
    }
}

enum CollectionEndpoint: Endpoint {
    case details(id: Int)

    var path: String {
        switch self {
        case .details(let id): "collection/\(id)"
        }
    }
}
