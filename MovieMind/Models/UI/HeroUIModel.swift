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
}
