//
//  UpcomingPageViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation
import SwiftUI
internal import Combine

struct UpcomingUIModel: Identifiable {
    let id: Int
    let mediaType: MediaType
    let result: MediaItem
    let genreNames: [String]
}

@MainActor
final class UpcomingPageViewModel: ObservableObject {
    
    
    @Published private(set) var state: ViewState<[UpcomingUIModel]> = .idle
    
    private let networkService: NetworkServicing
    private let genreStore: GenreStore
    
    init(networkService: NetworkServicing = NetworkManager.shared,
         genreStore: GenreStore = .shared) {
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
            let genreDictionary = await genreStore.genreDictionary()
            
            async let movies = networkService.fetchList(for: .upcomingMovies)
            async let tvShows = try? networkService.fetchList(for: .upcomingTV)
            
            let movieList = try await movies.stamping(.movie)
            let tvList = await tvShows?.stamping(.tv)
            
            let combined = (movieList.results ?? []) + (tvList?.results ?? [])
            
            let mappedItems: [UpcomingUIModel] = combined.compactMap { item in
                guard let id = item.id else { return nil }
                let names = (item.genreIds ?? []).compactMap { genreDictionary[$0] }
                return UpcomingUIModel(id: id,
                                       mediaType: item.mediaType ?? .movie,
                                       result: item,
                                       genreNames: names)
            }
            
            let sortedItems = mappedItems.sorted { first, second in
                guard let a = first.result.displayDate, !a.isEmpty else { return false }
                guard let b = second.result.displayDate, !b.isEmpty else { return true }
                return a < b
            }

            await prefetchPosterImages(for: sortedItems)

            withAnimation(.easeInOut(duration: 0.4)) {
                state = .loaded(sortedItems)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func prefetchPosterImages(for items: [UpcomingUIModel]) async {
        var urls: [URL] = []

        for item in items {
            let path = item.result.displayPath
            if let large = TMDBImage.url(for: path, size: .w500) {
                urls.append(large)
            }
            if let small = TMDBImage.url(for: path, size: .w200) {
                urls.append(small)
            }
        }

        await ImagePrefetcher.prefetch(urls)
    }
}
