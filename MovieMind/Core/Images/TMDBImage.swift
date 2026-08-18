//
//  TMDBImage.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

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
