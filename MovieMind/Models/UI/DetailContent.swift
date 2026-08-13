//
//  DetailContent.swift
//  MovieMind
//
//  Created by Semih Söğüt on 13.08.2026.
//

import Foundation

/// The one detail response a screen is showing.
///
/// Three separate optionals would let "movie and tv at once" or "none of them"
/// be represented; this cannot.
enum DetailContent {
    case movie(MovieDetail)
    case tv(TVDetail)
    case person(PersonDetail)
}
