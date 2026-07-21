//
//  HomePageViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import Foundation
import SwiftUI
internal import Combine

struct HeroUIModel: Identifiable {
    let id: Int
    let result: MediaItem
    let images: Images?
    let genreNames: [String]
}

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
final class HomePageViewModel: ObservableObject {
    
    @Published private(set) var state: ViewState<[HeroUIModel]> = .idle
    
    @Published var trendingType: MediaTypeForPicker? = .movie
    @Published var topRatedType: MediaTypeForPicker? = .movie
    @Published var popularType: MediaTypeForPicker? = .movie
    
    @Published private(set) var nowPlayingM: ListRespond?
    @Published private(set) var trendingMT: ListRespond?
    @Published private(set) var topRatedMT: ListRespond?
    @Published private(set) var popularMT: ListRespond?
    @Published private(set) var airingT: ListRespond?
    @Published private(set) var popularP: ListRespond?

    @Published private(set) var recommendations: [MediaItem] = []

    private var trendingAll: ListRespond?
    private var lastSeedSignature: String?

    private let networkService: NetworkServicing
    private let genreStore: GenreStore
    private let recommender: AIRecommendationService

    init(networkService: NetworkServicing = NetworkManager.shared,
         genreStore: GenreStore = .shared,
         recommender: AIRecommendationService = .shared) {
        self.networkService = networkService
        self.genreStore = genreStore
        self.recommender = recommender
    }
    
    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }
    
    func load() async {
        state = .loading

        do {
            try await fetchAllSections()
            let heroItems = await buildHeroItems()
            await prefetchPosterImages(heroItems: heroItems)
            withAnimation(.easeInOut(duration: 0.4)) {
                state = .loaded(heroItems)
            }

            if trendingType != .movie { await refetchSection(.trending) }
            if topRatedType != .movie { await refetchSection(.topRated) }
            if popularType != .movie { await refetchSection(.popular) }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func prefetchPosterImages(heroItems: [HeroUIModel]) async {
        var urls: [URL] = []

        for item in heroItems {
            let posterPath = item.images?.bestPoster ?? item.result.displayPath
            if let url = TMDBImage.url(for: posterPath, size: .w780) {
                urls.append(url)
            }

            if let logoURL = TMDBImage.url(for: item.images?.bestLogo(), size: .w500) {
                urls.append(logoURL)
            }
        }

        for list in [nowPlayingM, trendingMT, topRatedMT, popularMT, airingT, popularP] {
            urls.append(contentsOf: posterURLs(in: list))
        }

        await ImagePrefetcher.prefetch(urls)
    }

    private func prefetchPosterImages(for list: ListRespond) async {
        await ImagePrefetcher.prefetch(posterURLs(in: list))
    }

    private func posterURLs(in list: ListRespond?) -> [URL] {
        (list?.results ?? []).compactMap { TMDBImage.url(for: $0.displayPath, size: .w500) }
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
        var preparedItems: [HeroUIModel] = []
        
        await withTaskGroup(of: HeroUIModel?.self) { group in
            for item in results {
                guard let id = item.id, let mediaType = item.mediaType else { continue }
                
                group.addTask { [networkService] in
                    let fetchedImages = try? await networkService.fetchImages(id: id, for: mediaType)
                    let names = (item.genreIds ?? []).compactMap { genreDictionary[$0] }
                    return HeroUIModel(id: id, result: item, images: fetchedImages, genreNames: names)
                }
            }
            
            for await model in group {
                if let model { preparedItems.append(model) }
            }
        }
        
        return results.compactMap { original in
            preparedItems.first(where: { $0.id == original.id })
        }
    }
    
    
    func loadRecommendations(seeds: [WatchlistSeed]) async {
        guard !seeds.isEmpty else {
            recommendations = []
            lastSeedSignature = nil
            return
        }

        let signature = seeds
            .map { "\($0.mediaType.rawValue):\($0.title)" }
            .sorted()
            .joined(separator: "|")
        guard signature != lastSeedSignature else { return }

        do {
            try await Task.sleep(for: .seconds(2))
        } catch {
            return
        }

        guard let items = try? await recommender.recommend(from: seeds), !items.isEmpty else {
            return
        }

        lastSeedSignature = signature
        withAnimation(.easeInOut(duration: 0.4)) {
            recommendations = items
        }
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
