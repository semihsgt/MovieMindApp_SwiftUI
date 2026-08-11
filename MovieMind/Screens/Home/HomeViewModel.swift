//
//  HomeViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import Foundation
import SwiftUI

enum MediaTypeForPicker: String, CaseIterable, Identifiable {
    case movie = "Movie"
    case tv = "TV"
    var id: Self { self }
}

enum PickerSection {
    case trending
    case topRated
    case popular
}

@MainActor
@Observable
final class HomeViewModel {

    /// Hero cards whose images are fetched before Home is shown.
    private static let eagerHeroImageCount = 3
    
    private(set) var state: ViewState<[HeroUIModel]> = .idle

    var trendingType: MediaTypeForPicker? = .movie
    var topRatedType: MediaTypeForPicker? = .movie
    var popularType: MediaTypeForPicker? = .movie

    private(set) var nowPlayingM: ListRespond?
    private(set) var trendingMT: ListRespond?
    private(set) var topRatedMT: ListRespond?
    private(set) var popularMT: ListRespond?
    private(set) var airingT: ListRespond?
    private(set) var popularP: ListRespond?

    private var trendingAll: ListRespond?

    private let networkService: ListServicing & MediaImageServicing
    private let genreStore: GenreProviding

    init(networkService: ListServicing & MediaImageServicing = NetworkManager.shared,
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
            try await fetchAllSections()

            var heroItems = await buildHeroItems()
            heroItems = await withHeroImages(heroItems, in: 0..<Self.eagerHeroImageCount)

            await prefetchPosterImages(heroItems: heroItems)
            withAnimation(.easeInOut(duration: 0.4)) {
                state = .loaded(heroItems)
            }

            if trendingType != .movie { await refetchSection(.trending) }
            if topRatedType != .movie { await refetchSection(.topRated) }
            if popularType != .movie { await refetchSection(.popular) }

            await loadRemainingHeroImages()
        } catch {
            state = .failed(error)
        }
    }

    private func prefetchPosterImages(heroItems: [HeroUIModel]) async {
        await prefetchHeroImages(heroItems)

        let listPaths = [nowPlayingM, trendingMT, topRatedMT, popularMT, airingT, popularP]
            .flatMap { posterPaths(in: $0) }
        await ImagePrefetching.shared.prefetch(listPaths, size: .w500)
    }

    private func prefetchPosterImages(for list: ListRespond) async {
        await ImagePrefetching.shared.prefetch(posterPaths(in: list), size: .w500)
    }

    private func prefetchHeroImages(_ items: [HeroUIModel]) async {
        await ImagePrefetching.shared.prefetch(
            items.map { $0.images?.bestPoster ?? $0.result.displayPath }, size: .w780
        )
        await ImagePrefetching.shared.prefetch(items.map { $0.images?.bestLogo() }, size: .w500)
    }

    private func posterPaths(in list: ListRespond?) -> [String] {
        (list?.results ?? []).map(\.displayPath)
    }

    private func fetchAllSections() async throws {
        async let all = networkService.fetchList(for: .trendingAll)
        async let nowM = try? networkService.fetchList(for: .nowPlayingMovies)
        async let trendMT = try? networkService.fetchList(for: .trendingMovies)
        async let topMT = try? networkService.fetchList(for: .topRatedMovies)
        async let popMT = try? networkService.fetchList(for: .popularMovies)
        async let airT = try? networkService.fetchList(for: .airingTodayTV)
        async let popP = try? networkService.fetchList(for: .popularPeople)

        self.trendingAll = try await all
        let (nowMR, trendMTR, topMTR, popMTR, airTR, popPR)
        = await (nowM, trendMT, topMT, popMT, airT, popP)

        self.nowPlayingM = nowMR?.stamping(.movie)
        self.trendingMT = trendMTR?.stamping(.movie)
        self.topRatedMT = topMTR?.stamping(.movie)
        self.popularMT = popMTR?.stamping(.movie)
        self.airingT = airTR?.stamping(.tv)
        self.popularP = popPR?.stamping(.person)
    }

    private func buildHeroItems() async -> [HeroUIModel] {
        guard let results = trendingAll?.results else { return [] }
        let genreDictionary = await genreStore.genreDictionary()

        return results.compactMap { item in
            guard let id = item.id, item.mediaType != nil else { return nil }
            let names = (item.genreIds ?? []).compactMap { genreDictionary[$0] }
            return HeroUIModel(id: id, result: item, images: nil, genreNames: names)
        }
    }

    private func withHeroImages(_ items: [HeroUIModel], in range: Range<Int>) async -> [HeroUIModel] {
        let window = range.clamped(to: items.indices)
        guard !window.isEmpty else { return items }

        var updated = items

        await withTaskGroup(of: (Int, Images?).self) { group in
            for index in window {
                let item = items[index]
                guard item.images == nil, let mediaType = item.result.mediaType else { continue }
                let id = item.id

                group.addTask { [networkService] in
                    (index, try? await networkService.fetchImages(id: id, for: mediaType))
                }
            }

            for await (index, images) in group {
                if let images { updated[index].images = images }
            }
        }

        return updated
    }

    /// Fills in the cards the user hasn't swiped to yet, after Home is visible.
    private func loadRemainingHeroImages() async {
        guard let items = state.value, items.count > Self.eagerHeroImageCount else { return }

        let updated = await withHeroImages(items, in: Self.eagerHeroImageCount..<items.count)

        guard !Task.isCancelled,
              let current = state.value,
              current.map(\.id) == items.map(\.id) else { return }

        state = .loaded(updated)
        await prefetchHeroImages(Array(updated.dropFirst(Self.eagerHeroImageCount)))
    }

    func refetchSection(_ section: PickerSection) async {
        guard case .loaded = state else { return }

        do {
            switch section {
            case .trending:
                guard let type = trendingType else { return }
                let result = try await networkService.fetchList(
                    for: type == .movie ? .trendingMovies : .trendingTV
                ).stamping(type == .movie ? .movie : .tv)
                await prefetchPosterImages(for: result)
                trendingMT = result
            case .topRated:
                guard let type = topRatedType else { return }
                let result = try await networkService.fetchList(
                    for: type == .movie ? .topRatedMovies : .topRatedTV
                ).stamping(type == .movie ? .movie : .tv)
                await prefetchPosterImages(for: result)
                topRatedMT = result
            case .popular:
                guard let type = popularType else { return }
                let result = try await networkService.fetchList(
                    for: type == .movie ? .popularMovies : .popularTV
                ).stamping(type == .movie ? .movie : .tv)
                await prefetchPosterImages(for: result)
                popularMT = result
            }
        } catch {
            // Section keeps its previous content on failure
        }
    }
}
