//
//  DetailViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class DetailViewModel {

    private(set) var state: ViewState<HeroUIModel> = .idle
    private(set) var content: DetailContent?
    private(set) var knownFor: [MediaItem] = []
    private(set) var similar: ListRespond?
    private(set) var watchProviders: CountryWatchProviders?

    private let networkService: DetailServicing & MediaImageServicing
    private let prefetcher = ImagePrefetching()
    private var loadedKey: String?

    init(networkService: DetailServicing & MediaImageServicing = NetworkManager.shared) {
        self.networkService = networkService
    }

    /// Loads once per title. Safe to call from `.task`, which re-fires on every
    /// return to the screen; use `load` directly to force a retry.
    func loadIfNeeded(id: Int, mediaType: MediaType) async {
        let key = "\(mediaType.rawValue)-\(id)"
        guard key != loadedKey else { return }
        loadedKey = key
        await load(id: id, mediaType: mediaType)
    }

    /// Called on disappear so images for a screen the user left don't compete with
    /// the one they moved to.
    func cancelPrefetching() {
        prefetcher.cancelAll()
    }

    func load(id: Int, mediaType: MediaType) async {
        state = .loading
        prefetcher.cancelAll()

        content = nil
        similar = nil
        watchProviders = nil
        knownFor = []

        switch mediaType {
        case .movie:  await loadMovie(id: id)
        case .tv:     await loadTV(id: id)
        case .person: await loadPerson(id: id)
        }
    }

    private func loadMovie(id: Int) async {
        async let detail: MovieDetail = networkService.fetchDetails(id: id, for: .movie)
        async let images = try? networkService.fetchImages(id: id, for: .movie)
        async let similarList = try? networkService.fetchSimilar(id: id, for: .movie)
        async let providers = try? networkService.fetchWatchProviders(id: id, for: .movie)

        do {
            let movie = try await detail
            let (fetchedImages, similarResult, providerResult) = await (images, similarList, providers)

            content = .movie(movie)
            similar = similarResult?.stamping(.movie)
            watchProviders = Self.pickRegion(from: providerResult)

            guard let hero = HeroUIModelMapper.map(movie, images: fetchedImages) else {
                return missingDetail()
            }

            prefetchDetailImages(hero: hero,
                                       castProfiles: movie.cast,
                                       collectionBackdrop: movie.belongsToCollection?.backdropPath)
            show(hero)
        } catch {
            state = .failed(error)
        }
    }

    private func loadTV(id: Int) async {
        async let detail: TVDetail = networkService.fetchDetails(id: id, for: .tv)
        async let images = try? networkService.fetchImages(id: id, for: .tv)
        async let similarList = try? networkService.fetchSimilar(id: id, for: .tv)
        async let providers = try? networkService.fetchWatchProviders(id: id, for: .tv)

        do {
            let tv = try await detail
            let (fetchedImages, similarResult, providerResult) = await (images, similarList, providers)

            content = .tv(tv)
            similar = similarResult?.stamping(.tv)
            watchProviders = Self.pickRegion(from: providerResult)

            guard let hero = HeroUIModelMapper.map(tv, images: fetchedImages) else {
                return missingDetail()
            }

            prefetchDetailImages(hero: hero,
                                       castProfiles: tv.cast,
                                       seasons: tv.seasons,
                                       episodeStills: tv.episodeStills)
            show(hero)
        } catch {
            state = .failed(error)
        }
    }

    private func loadPerson(id: Int) async {
        async let detail: PersonDetail = networkService.fetchDetails(id: id, for: .person)
        async let images = try? networkService.fetchImages(id: id, for: .person)
        async let credits = try? networkService.fetchPersonCredits(id: id)

        do {
            let person = try await detail
            let (fetchedImages, creditsResult) = await (images, credits)

            content = .person(person)
            knownFor = Self.topCredits(from: creditsResult)

            guard let hero = HeroUIModelMapper.map(person, images: fetchedImages) else {
                return missingDetail()
            }

            prefetchDetailImages(hero: hero, knownFor: knownFor)
            show(hero)
        } catch {
            state = .failed(error)
        }
    }

    private func show(_ hero: HeroUIModel) {
        withAnimation(.easeInOut(duration: 0.4)) {
            state = .loaded(hero)
        }
    }

    private func missingDetail() {
        state = .failed(NetworkError.incompleteData)
    }

    /// The 20 most popular credits, one row per person.
    private static func topCredits(from credits: CombinedCredits?) -> [MediaItem] {
        guard let credits else { return [] }

        var seen = Set<Int>()
        let unique = credits.cast.filter { item in
            guard let id = item.id else { return false }
            return seen.insert(id).inserted
        }
        return Array(unique.sorted { $0.popularity > $1.popularity }.prefix(20))
    }

    private static func pickRegion(from response: WatchProviderResponse?) -> CountryWatchProviders? {
        guard let results = response?.results, !results.isEmpty else { return nil }
        let regionCode = Locale.current.region?.identifier ?? "US"
        return results[regionCode] ?? results["US"] ?? results.values.first
    }

    private func prefetchDetailImages(
        hero: HeroUIModel,
        castProfiles: [CastMember] = [],
        knownFor: [MediaItem] = [],
        collectionBackdrop: String? = nil,
        seasons: [Season] = [],
        episodeStills: [String?] = []
    ) {
        prefetcher.prefetch([hero.images?.bestPoster ?? hero.result.displayPath], size: .w780)
        prefetcher.prefetch([hero.images?.bestLogo()], size: .w500)

        var thumbnails: [String?] = castProfiles.map(\.profilePath)
        thumbnails += seasons.map(\.posterPath)
        thumbnails += episodeStills
        thumbnails += (watchProviders?.all ?? []).map(\.logoPath)

        var posters: [String?] = knownFor.map(\.displayPath)
        posters += (similar?.results ?? []).map(\.displayPath)
        posters.append(collectionBackdrop)

        prefetcher.prefetch(thumbnails, size: .w200)
        prefetcher.prefetch(posters, size: .w500)
    }
}
