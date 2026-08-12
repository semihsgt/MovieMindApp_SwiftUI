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
        images: Images(id: 1356210, logos: [], posters: []),
        genreNames: ["Acting"]
    )
}

// MARK: - Detail section samples

extension Season {
    static let preview = Season(id: 1,
                                name: "Season 1",
                                seasonNumber: 1,
                                episodeCount: 9,
                                posterPath: "/aUCiBTNbBoM4dP4YBmVMSnzRLDG.jpg")

    /// TMDB sometimes omits the name; `displayName` falls back to the number.
    static let previewUnnamed = Season(id: 2,
                                       name: "",
                                       seasonNumber: 2,
                                       episodeCount: 7,
                                       posterPath: nil)
}

extension TEpisodeToAir {
    static let preview = TEpisodeToAir(id: 10,
                                       name: "Future Days",
                                       seasonNumber: 2,
                                       episodeNumber: 1,
                                       airDate: "2025-04-13",
                                       stillPath: "/xnE0PPFTfcxHkQFVjfLNRRTxLST.jpg")
}

extension CastMember {
    static let previews = [
        CastMember(id: 1, name: "Pedro Pascal", character: "Joel Miller",
                   profilePath: "/9VYK7ovcH1eyfNjqNTn3Vd2yGRw.jpg", creditId: "c1"),
        CastMember(id: 2, name: "Bella Ramsey", character: "Ellie Williams",
                   profilePath: "/1kks3YnVkpyQxzw36iyHnPjEChs.jpg", creditId: "c2"),
        CastMember(id: 3, name: "Gabriel Luna", character: "Tommy Miller",
                   profilePath: nil, creditId: "c3")
    ]
}

extension BelongsToCollection {
    static let preview = BelongsToCollection(id: 726871,
                                             name: "Dune Collection",
                                             backdropPath: "/l4QHerTSbMI7qgvasqxP36pqjN6.jpg")
}

extension CountryWatchProviders {
    static let preview = CountryWatchProviders(
        flatrate: [WatchProvider(providerId: 8, providerName: "Netflix",
                                 logoPath: "/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg", displayPriority: 0)],
        rent: [WatchProvider(providerId: 2, providerName: "Apple TV",
                             logoPath: "/9ghgSC0MA082EL6HLCW3GalykFD.jpg", displayPriority: 1)],
        buy: [],
        free: [],
        ads: []
    )
}
