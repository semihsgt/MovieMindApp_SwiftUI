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
            voteCount: 8600,
            overview: "Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.",
            backdropPath: "/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg",
            posterPath: "/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg",
            originalLanguage: "en",
            genreIds: [878, 12],
            name: nil,
            title: "Dune: Part Two",
            originalTitle: "Dune: Part Two",
            releaseDate: "2024-02-27",
            video: false,
            originalName: nil,
            firstAirDate: nil,
            originCountry: nil,
            gender: nil,
            knownForDepartment: nil,
            profilePath: nil,
            knownFor: nil
        ),
        images: Images(
            id: 693134,
            backdrops: nil,
            logos: [
                ImageDetails(
                    iso31661: nil,
                    iso6391: "en",
                    width: 800,
                    height: 320,
                    aspectRatio: 2.5,
                    voteAverage: 5.0,
                    voteCount: 4,
                    filePath: "/eYvF1LhPKuoBxOAmWjFTAK7EPWl.png"
                )
            ],
            posters: [
                ImageDetails(
                    iso31661: nil,
                    iso6391: nil,
                    width: 2000,
                    height: 3000,
                    aspectRatio: 0.667,
                    voteAverage: 8.2,
                    voteCount: 30,
                    filePath: "/76upJ0fnQ3osESX8mkTyfuXK5Ju.jpg"
                )
            ],
            profiles: nil
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
            voteCount: 5400,
            overview: "Joel and Ellie, a pair connected through the harshness of the world they live in, are forced to endure brutal circumstances.",
            backdropPath: "/uDgy6hyPd82kOHh6I95FLtLnj6p.jpg",
            posterPath: "/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg",
            originalLanguage: "en",
            genreIds: [18, 10765, 10759],
            name: "The Last of Us",
            title: nil,
            originalTitle: nil,
            releaseDate: nil,
            video: nil,
            originalName: "The Last of Us",
            firstAirDate: "2023-01-15",
            originCountry: ["US"],
            gender: nil,
            knownForDepartment: nil,
            profilePath: nil,
            knownFor: nil
        ),
        images: Images(
            id: 100088,
            backdrops: nil,
            logos: [
                ImageDetails(
                    iso31661: nil,
                    iso6391: "en",
                    width: 800,
                    height: 260,
                    aspectRatio: 3.1,
                    voteAverage: 5.0,
                    voteCount: 6,
                    filePath: "/msYtgZbEo8tAOJ37T50kgqulpKf.png"
                )
            ],
            posters: [
                ImageDetails(
                    iso31661: nil,
                    iso6391: nil,
                    width: 2000,
                    height: 3000,
                    aspectRatio: 0.667,
                    voteAverage: 8.5,
                    voteCount: 20,
                    filePath: "/qD7rmFLD5ZChiVP13uqnTeypYEF.jpg"
                )
            ],
            profiles: nil
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
            voteAverage: nil,
            voteCount: nil,
            overview: nil,
            backdropPath: nil,
            posterPath: nil,
            originalLanguage: nil,
            genreIds: nil,
            name: "Millie Bobby Brown",
            title: nil,
            originalTitle: nil,
            releaseDate: nil,
            video: nil,
            originalName: "Millie Bobby Brown",
            firstAirDate: nil,
            originCountry: nil,
            gender: 1,
            knownForDepartment: "Acting",
            profilePath: "/kHO7hdNEVuTnQ0OjjrxP1RcAa0e.jpg",
            knownFor: [
                KnownFor(
                    adult: false,
                    backdropPath: "/56v2KjBlU4XaOv9rVYEQypROD7P.jpg",
                    id: 66732,
                    name: "Stranger Things",
                    originalName: "Stranger Things",
                    overview: "When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.",
                    posterPath: "/49WJfeN0moxb9IPfGn8AIqMGskD.jpg",
                    mediaType: .tv,
                    originalLanguage: "en",
                    genreIds: [18, 10765],
                    popularity: 185.2,
                    firstAirDate: "2016-07-15",
                    voteAverage: 8.6,
                    voteCount: 17200,
                    originCountry: ["US"],
                    title: nil,
                    originalTitle: nil,
                    releaseDate: nil,
                    video: nil
                )
            ]
        ),
        images: Images(
            id: 1356210,
            backdrops: nil,
            logos: nil,
            posters: nil,
            profiles: [
                ImageDetails(
                    iso31661: nil,
                    iso6391: nil,
                    width: 441,
                    height: 662,
                    aspectRatio: 0.666,
                    voteAverage: 5.5,
                    voteCount: 38,
                    filePath: "/kHO7hdNEVuTnQ0OjjrxP1RcAa0e.jpg"
                )
            ]
        ),
        genreNames: ["Acting"]
    )
}
