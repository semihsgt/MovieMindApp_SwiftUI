//
//  DetailPageViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class DetailPageViewModel: ObservableObject {
    
    private let networkService: NetworkServicing
    
    @Published private(set) var state: ViewState<HeroUIModel> = .idle
    
    private(set) var knownFor: [MediaItem]?
    
    private(set) var movieDetail: MovieDetail?
    private(set) var tvDetail: TVDetail?
    private(set) var personDetail: PersonDetail?
    private(set) var similar: ListRespond?
    private(set) var watchProviders: CountryWatchProviders?
    
    private var loadedKey: String?
    
    init(networkService: NetworkServicing = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func loadIfNeeded(id: Int, mediaType: MediaType) async {
        let key = "\(mediaType.rawValue)-\(id)"
        guard key != loadedKey else { return }
        loadedKey = key
        await load(id: id, mediaType: mediaType)
    }
    
    func load(id: Int, mediaType: MediaType) async {
        state = .loading

        movieDetail = nil
        tvDetail = nil
        personDetail = nil
        similar = nil
        watchProviders = nil
        knownFor = nil

        switch mediaType {
        case .movie:  await loadMovie(id: id)
        case .tv:     await loadTV(id: id)
        case .person: await loadPerson(id: id)
        }
    }
    
    private static func topCredits(from credits: CombinedCredits?) -> [MediaItem]? {
        guard let cast = credits?.cast, !cast.isEmpty else { return nil }
        var seen = Set<Int>()
        let unique = cast.filter { item in
            guard let id = item.id else { return false }
            return seen.insert(id).inserted
        }
        return Array(unique.sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }.prefix(20))
    }
    
    
    private func loadMovie(id: Int) async {
        async let detail: MovieDetail = networkService.fetchDetails(id: id, for: .movie)
        async let images = try? networkService.fetchImages(id: id, for: .movie)
        async let similarList = try? networkService.fetchSimilar(id: id, for: .movie)
        async let providers = try? networkService.fetchWatchProviders(id: id, for: .movie)
        
        do {
            let d = try await detail
            let (imagesR, similarR, providersR) = await (images, similarList, providers)
            
            self.movieDetail = d
            self.similar = similarR?.stamping(.movie)
            self.watchProviders = Self.pickRegion(from: providersR)
            
            guard let dId = d.id else {
                state = .failed("Details could not be loaded.")
                return
            }
            
            let item = MediaItem(
                id: dId,
                mediaType: .movie,
                adult: d.adult,
                popularity: d.popularity,
                voteAverage: d.voteAverage,
                voteCount: d.voteCount,
                overview: d.overview,
                backdropPath: d.backdropPath,
                posterPath: d.posterPath,
                originalLanguage: d.originalLanguage,
                genreIds: d.genres?.compactMap(\.id),
                name: nil,
                title: d.title,
                originalTitle: d.originalTitle,
                releaseDate: d.releaseDate,
                video: d.video,
                originalName: nil,
                firstAirDate: nil,
                originCountry: d.originCountry,
                gender: nil,
                knownForDepartment: nil,
                profilePath: nil,
                knownFor: nil
            )
            
            let heroItem = HeroUIModel(
                id: dId,
                result: item,
                images: imagesR,
                genreNames: d.genres?.compactMap(\.name) ?? []
            )

            await prefetchDetailImages(
                hero: heroItem,
                castProfiles: d.credits?.cast,
                collectionBackdrop: d.belongsToCollection?.backdropPath
            )

            withAnimation(.easeInOut(duration: 0.4)) {
                state = .loaded(heroItem)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }


    private func loadTV(id: Int) async {
        async let detail: TVDetail = networkService.fetchDetails(id: id, for: .tv)
        async let images = try? networkService.fetchImages(id: id, for: .tv)
        async let similarList = try? networkService.fetchSimilar(id: id, for: .tv)
        async let providers = try? networkService.fetchWatchProviders(id: id, for: .tv)
        
        do {
            let d = try await detail
            let (imagesR, similarR, providersR) = await (images, similarList, providers)
            
            self.tvDetail = d
            self.similar = similarR?.stamping(.tv)
            self.watchProviders = Self.pickRegion(from: providersR)
            
            guard let dId = d.id else {
                state = .failed("Details could not be loaded.")
                return
            }
            
            let item = MediaItem(
                id: dId,
                mediaType: .tv,
                adult: d.adult,
                popularity: d.popularity,
                voteAverage: d.voteAverage,
                voteCount: d.voteCount,
                overview: d.overview,
                backdropPath: d.backdropPath,
                posterPath: d.posterPath,
                originalLanguage: d.originalLanguage,
                genreIds: d.genres?.compactMap(\.id),
                name: d.name,
                title: nil,
                originalTitle: nil,
                releaseDate: nil,
                video: nil,
                originalName: d.originalName,
                firstAirDate: d.firstAirDate,
                originCountry: d.originCountry,
                gender: nil,
                knownForDepartment: nil,
                profilePath: nil,
                knownFor: nil
            )
            
            let heroItem = HeroUIModel(
                id: dId,
                result: item,
                images: imagesR,
                genreNames: d.genres?.compactMap(\.name) ?? []
            )

            await prefetchDetailImages(
                hero: heroItem,
                castProfiles: d.credits?.cast,
                seasons: d.seasons,
                episodeStills: [d.nextEpisodeToAir?.stillPath, d.lastEpisodeToAir?.stillPath]
            )

            withAnimation(.easeInOut(duration: 0.4)) {
                state = .loaded(heroItem)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }


    private func loadPerson(id: Int) async {
        async let detail: PersonDetail = networkService.fetchDetails(id: id, for: .person)
        async let images = try? networkService.fetchImages(id: id, for: .person)
        async let credits = try? networkService.fetchPersonCredits(id: id)
        
        do {
            let d = try await detail
            let imagesR = await images
            
            self.personDetail = d
            let creditsR = await credits
            self.knownFor = Self.topCredits(from: creditsR)
            
            guard let dId = d.id else {
                state = .failed("Details could not be loaded.")
                return
            }
            
            let item = MediaItem(
                id: dId,
                mediaType: .person,
                adult: d.adult,
                popularity: d.popularity,
                voteAverage: nil,
                voteCount: nil,
                overview: nil,
                backdropPath: nil,
                posterPath: nil,
                originalLanguage: nil,
                genreIds: nil,
                name: d.name,
                title: nil,
                originalTitle: nil,
                releaseDate: nil,
                video: nil,
                originalName: d.name,
                firstAirDate: nil,
                originCountry: nil,
                gender: d.gender,
                knownForDepartment: d.knownForDepartment,
                profilePath: d.profilePath,
                knownFor: nil
            )
            
            let heroItem = HeroUIModel(
                id: dId,
                result: item,
                images: imagesR,
                genreNames: [d.knownForDepartment].compactMap { $0 }
            )

            await prefetchDetailImages(hero: heroItem, knownFor: knownFor)

            withAnimation(.easeInOut(duration: 0.4)) {
                state = .loaded(heroItem)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    
    private static func pickRegion(from response: WatchProviderResponse?) -> CountryWatchProviders? {
        guard let results = response?.results, !results.isEmpty else { return nil }
        let regionCode = Locale.current.region?.identifier ?? "US"
        return results[regionCode] ?? results["US"] ?? results.values.first
    }

    private func prefetchDetailImages(
        hero: HeroUIModel,
        castProfiles: [CastMember]? = nil,
        knownFor: [MediaItem]? = nil,
        collectionBackdrop: String? = nil,
        seasons: [Season]? = nil,
        episodeStills: [String?] = []
    ) async {
        var heroURLs: [URL] = []
        let posterPath = hero.images?.bestPoster ?? hero.result.displayPath
        if let url = TMDBImage.url(for: posterPath, size: .w780) {
            heroURLs.append(url)
        }
        if let logoURL = TMDBImage.url(for: hero.images?.bestLogo(), size: .w500) {
            heroURLs.append(logoURL)
        }

        var restURLs: [URL] = []
        restURLs.append(contentsOf: (castProfiles ?? []).compactMap { TMDBImage.url(for: $0.profilePath, size: .w200) })
        restURLs.append(contentsOf: (knownFor ?? []).compactMap { TMDBImage.url(for: $0.displayPath, size: .w500) })
        restURLs.append(contentsOf: (seasons ?? []).compactMap { TMDBImage.url(for: $0.posterPath, size: .w200) })
        restURLs.append(contentsOf: episodeStills.compactMap { TMDBImage.url(for: $0, size: .w200) })

        if let collectionBackdrop, let url = TMDBImage.url(for: collectionBackdrop, size: .w500) {
            restURLs.append(url)
        }

        restURLs.append(contentsOf: (similar?.results ?? []).compactMap { TMDBImage.url(for: $0.displayPath, size: .w500) })
        restURLs.append(contentsOf: providerImageURLs(from: watchProviders))

        await ImagePrefetcher.prefetch(heroURLs)

        Task {
            await ImagePrefetcher.prefetch(restURLs)
        }
    }

    private func providerImageURLs(from providers: CountryWatchProviders?) -> [URL] {
        guard let providers else { return [] }
        let all = (providers.flatrate ?? []) + (providers.free ?? [])
            + (providers.ads ?? []) + (providers.rent ?? []) + (providers.buy ?? [])
        return all.compactMap { TMDBImage.url(for: $0.logoPath, size: .w200) }
    }
}
