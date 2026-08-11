//
//  HeroUIModelMapper.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import Foundation

/// Turns the detail responses into the hero model the UI renders.
/// Returns nil when the response has no usable id.
enum HeroUIModelMapper {

    static func map(_ movie: MovieDetail, images: Images?) -> HeroUIModel? {
        guard let id = movie.id else { return nil }

        let item = MediaItem(id: id,
                             mediaType: .movie,
                             adult: movie.adult,
                             popularity: movie.popularity,
                             voteAverage: movie.voteAverage,
                             posterPath: movie.posterPath,
                             genreIds: movie.genres?.compactMap(\.id),
                             title: movie.title,
                             releaseDate: movie.releaseDate)

        return HeroUIModel(id: id,
                           result: item,
                           images: images,
                           genreNames: movie.genres?.compactMap(\.name) ?? [])
    }

    static func map(_ tv: TVDetail, images: Images?) -> HeroUIModel? {
        guard let id = tv.id else { return nil }

        let item = MediaItem(id: id,
                             mediaType: .tv,
                             adult: tv.adult,
                             popularity: tv.popularity,
                             voteAverage: tv.voteAverage,
                             posterPath: tv.posterPath,
                             genreIds: tv.genres?.compactMap(\.id),
                             name: tv.name,
                             firstAirDate: tv.firstAirDate)

        return HeroUIModel(id: id,
                           result: item,
                           images: images,
                           genreNames: tv.genres?.compactMap(\.name) ?? [])
    }

    static func map(_ person: PersonDetail, images: Images?) -> HeroUIModel? {
        guard let id = person.id else { return nil }

        let item = MediaItem(id: id,
                             mediaType: .person,
                             adult: person.adult,
                             popularity: person.popularity,
                             name: person.name,
                             knownForDepartment: person.knownForDepartment,
                             profilePath: person.profilePath)

        return HeroUIModel(id: id,
                           result: item,
                           images: images,
                           genreNames: [person.knownForDepartment].compactMap { $0 })
    }
}
