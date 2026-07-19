//
//  DetailPageView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI
import FluidHeader

struct DetailPageView: View {
    @StateObject private var viewModel = DetailPageViewModel()
    let id: Int
    let mediaType: MediaType
    
    var body: some View {
        StateContainerView(state: viewModel.state) {
            await viewModel.load(id: id, mediaType: mediaType)
        } loading: {
            skeletonView
        } content: { item in
            detailScrollContent(for: item)
        }
        .toolbar {
            if let item = viewModel.state.value {
                ToolbarItem(placement: .topBarTrailing) {
                    WatchlistButton(
                        mediaId: item.id,
                        mediaType: item.result.mediaType ?? .movie,
                        displayName: item.result.displayName,
                        posterPath: item.result.displayPath,
                        diameter: 36,
                        showsBackground: false
                    )
                    .frame(width: 36, height: 36)
                }
            }
        }
        .task(id: "\(mediaType.rawValue)-\(id)") {
            await viewModel.loadIfNeeded(id: id, mediaType: mediaType)
        }

    }

    private func detailScrollContent(for item: HeroUIModel) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                FluidHeader {
                    HeroCard(item: item, isButtonDisplayed: false)
                }
                .fluidHeaderBlurOffset(220)
                .fluidHeaderBlurHeight(40)
                .fluidHeaderOpacityHeight(300)

                detailContent(for: item)
                    .padding(.top, 24)
                    .background(Color.black)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    var skeletonView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroSkeleton

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 14)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 14)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 180, height: 14)
                            .shimmer()
                    }
                    .padding(.horizontal)

                    castRowSkeleton
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
                .background(Color.black)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var heroSkeleton: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .shimmer()
            .aspectRatio(2/3, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)
    }

    private var castRowSkeleton: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 100, height: 150)
                        .shimmer()
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func detailContent(for hero: HeroUIModel) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            if let movie = viewModel.movieDetail {
                OverviewSection(tagline: movie.tagline, overview: movie.overview)
                GenreChipsRow(names: hero.genreNames)
                MetadataRow(items: movieMetadata(movie))
                CreditLine(label: "Director", names: directorNames(movie))
                CastSection(cast: movie.credits?.cast)
                if let collection = movie.belongsToCollection, let collectionId = collection.id {
                    NavigationLink(value: CollectionRoute(id: collectionId, name: collection.name ?? "Collection")) {
                        CollectionBanner(collection: collection)
                    }
                    .buttonStyle(.plain)
                }
            } else if let tv = viewModel.tvDetail {
                OverviewSection(tagline: tv.tagline, overview: tv.overview)
                GenreChipsRow(names: hero.genreNames)
                MetadataRow(items: tvMetadata(tv))
                CreditLine(label: "Created by", names: (tv.createdBy ?? []).compactMap(\.name))
                EpisodeSection(title: "Next Episode", episode: tv.nextEpisodeToAir)
                EpisodeSection(title: "Last Episode", episode: tv.lastEpisodeToAir)
                CastSection(cast: tv.credits?.cast)
                SeasonsSection(seasons: tv.seasons)
            } else if let person = viewModel.personDetail {
                BiographySection(biography: person.biography)
                SectionView(title: "Known For",
                            description: "Most popular credits.",
                            data: viewModel.knownFor)
            }
            
            WatchProvidersSection(providers: viewModel.watchProviders)
            
            SectionView(title: "Similar",
                        description: "More like this.",
                        data: viewModel.similar?.results)
        }
        .padding(.bottom, 40)
    }
    
    private func directorNames(_ movie: MovieDetail) -> [String] {
        (movie.credits?.crew ?? [])
            .filter { $0.job == "Director" }
            .compactMap(\.name)
    }
    
    private func movieMetadata(_ movie: MovieDetail) -> [String] {
        var items: [String] = []
        if let year = movie.releaseDate?.prefix(4), !year.isEmpty { items.append(String(year)) }
        if let runtime = movie.runtime, runtime > 0 { items.append("\(runtime / 60)h \(runtime % 60)m") }
        if let vote = movie.voteAverage, vote > 0 { items.append(String(format: "★ %.1f", vote)) }
        if let status = movie.status, status != "Released" { items.append(status) }
        return items
    }
    
    private func tvMetadata(_ tv: TVDetail) -> [String] {
        var items: [String] = []
        if let year = tv.firstAirDate?.prefix(4), !year.isEmpty { items.append(String(year)) }
        if let seasons = tv.numberOfSeasons { items.append("\(seasons) Season\(seasons == 1 ? "" : "s")") }
        if let vote = tv.voteAverage, vote > 0 { items.append(String(format: "★ %.1f", vote)) }
        if let status = tv.status, status == "Ended" || status == "Canceled" { items.append(status) }
        return items
    }
    
}

#Preview("Movie") {
    NavigationStack {
        DetailPageView(id: 693134, mediaType: .movie)
    }
}

#Preview("TV") {
    NavigationStack {
        DetailPageView(id: 100088, mediaType: .tv)
    }
}

#Preview("Person") {
    NavigationStack {
        DetailPageView(id: 1356210, mediaType: .person)
    }
}

#Preview("Invalid ID") {
    NavigationStack {
        DetailPageView(id: 1353344343, mediaType: .movie)
    }
}

#Preview("Loading Skeleton") {
    NavigationStack {
        DetailPageView(id: 693134, mediaType: .movie).skeletonView
            .background(Color.black.ignoresSafeArea())
    }
}
