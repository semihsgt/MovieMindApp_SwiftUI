//
//  UpcomingPageViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class UpcomingPageViewModel {

    private(set) var state: ViewState<[UpcomingUIModel]> = .idle

    private let networkService: ListServicing
    private let genreStore: GenreProviding

    init(networkService: ListServicing = NetworkManager.shared,
         genreStore: GenreProviding = GenreStore.shared) {
        self.networkService = networkService
        self.genreStore = genreStore
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        state = .loading

        do {
            let genres = await genreStore.genreDictionary()

            async let movies = networkService.fetchList(for: .upcomingMovies)
            async let tvShows = try? networkService.fetchList(for: .upcomingTV)

            let movieList = try await movies.stamping(.movie)
            let tvList = await tvShows?.stamping(.tv)
            let combined = (movieList.results ?? []) + (tvList?.results ?? [])

            let items = UpcomingUIModelMapper.map(combined, genres: genres)

            // One asset per card; both placements downsample from it locally.
            await ImagePrefetching.shared.prefetch(items.map(\.result.displayPath), size: .w500)

            withAnimation(.easeInOut(duration: 0.4)) {
                state = .loaded(items)
            }
        } catch {
            state = .failed(error)
        }
    }
}
