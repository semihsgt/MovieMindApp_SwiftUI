//
//  HeroUIModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import Foundation

struct HeroUIModel: Identifiable, Sendable {
    let id: Int
    let result: MediaItem
    var images: Images?
    let genreNames: [String]

    /// The trending carousel mixes movies, shows and people, so `id` alone can
    /// collide across them.
    var uniqueId: String { result.uniqueId }
}
