//
//  MediaTypeForPicker.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import Foundation

/// The Movie/TV choice a section's segmented picker offers.
///
/// Deliberately not `MediaType`: that enum has a `person` case the picker must
/// never show, and its raw values are TMDB path segments rather than labels.
enum MediaTypeForPicker: String, CaseIterable, Identifiable {
    case movie = "Movie"
    case tv = "TV"

    var id: Self { self }
}
