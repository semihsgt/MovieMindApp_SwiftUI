//
//  PreviewData.swift
//  MovieMind
//

import Foundation

extension HeroUIModel {

    static let previewMovie = HeroUIModel(
        id: 693134,
        result: MediaItem(
            id: 693134,
            mediaType: .movie,
            adult: false,
            popularity: 452.8,
            voteAverage: 8.2,
            posterPath: "/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg",
            genreIds: [878, 12],
            title: "Dune: Part Two",
            releaseDate: "2024-02-27"
        ),
        images: Images(
            id: 693134,
            logos: [ImageDetails(iso6391: "en", filePath: "/eYvF1LhPKuoBxOAmWjFTAK7EPWl.png")],
            posters: [ImageDetails(iso6391: nil, filePath: "/76upJ0fnQ3osESX8mkTyfuXK5Ju.jpg")]
        ),
        genreNames: ["Science Fiction", "Adventure", "Drama"]
    )

    static let previewTV = HeroUIModel(
        id: 100088,
        result: MediaItem(
            id: 100088,
            mediaType: .tv,
            adult: false,
            popularity: 320.4,
            voteAverage: 8.5,
            posterPath: "/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg",
            genreIds: [18, 10765, 10759],
            name: "The Last of Us",
            firstAirDate: "2023-01-15"
        ),
        images: Images(
            id: 100088,
            logos: [ImageDetails(iso6391: "en", filePath: "/msYtgZbEo8tAOJ37T50kgqulpKf.png")],
            posters: [ImageDetails(iso6391: nil, filePath: "/qD7rmFLD5ZChiVP13uqnTeypYEF.jpg")]
        ),
        genreNames: ["Drama", "Science Fiction"]
    )

    static let previewPerson = HeroUIModel(
        id: 1356210,
        result: MediaItem(
            id: 1356210,
            mediaType: .person,
            adult: false,
            popularity: 85.421,
            name: "Millie Bobby Brown",
            knownForDepartment: "Acting",
            profilePath: "/kHO7hdNEVuTnQ0OjjrxP1RcAa0e.jpg",
            knownFor: [KnownFor(name: "Stranger Things", title: nil)]
        ),
        images: Images(id: 1356210, logos: nil, posters: nil),
        genreNames: ["Acting"]
    )
}
