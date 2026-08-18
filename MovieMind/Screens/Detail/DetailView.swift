//
//  DetailView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI
import FluidHeader

struct DetailView: View {
    
    @State private var viewModel = DetailViewModel()
    let id: Int
    let mediaType: MediaType

    var body: some View {
        StateContainerView(state: viewModel.state) {
            await viewModel.load(id: id, mediaType: mediaType)
        } loading: {
            DetailSkeletonView()
        } content: { item in
            detailScrollContent(for: item)
        }
        .navigationTitle(viewModel.state.value?.result.displayName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let item = viewModel.state.value {
                ToolbarItem(placement: .topBarTrailing) {
                    LibraryButton(
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
        .onDisappear {
            viewModel.cancelPrefetching()
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
                    .darkFadeBackground()
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private func detailContent(for hero: HeroUIModel) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            switch viewModel.content {
            case .movie(let movie):   movieSections(movie, hero: hero)
            case .tv(let tv):         tvSections(tv, hero: hero)
            case .person(let person): personSections(person)
            case .none:               EmptyView()
            }

            WatchProvidersSection(providers: viewModel.watchProviders)

            SectionView(title: "Similar",
                        description: "More like this.",
                        data: viewModel.similar?.results ?? [])
        }
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private func movieSections(_ movie: MovieDetail, hero: HeroUIModel) -> some View {
        OverviewSection(tagline: movie.tagline, overview: movie.overview)
        GenreChipsRow(names: hero.genreNames)
        MetadataRow(items: movie.metadataItems)
        CreditLine(label: "Director", names: movie.directorNames)
        CastSection(cast: movie.cast)

        if let collection = movie.belongsToCollection, let collectionId = collection.id {
            let route = CollectionRoute(id: collectionId, name: collection.displayName)
            NavigationLink(value: route) {
                CollectionBanner(collection: collection)
            }
            .buttonStyle(.plain)
            .zoomSource(id: route)
            .accessibilityRepresentation {
                Button("Part of \(collection.displayName)") {}
            }
        }
    }

    @ViewBuilder
    private func tvSections(_ tv: TVDetail, hero: HeroUIModel) -> some View {
        OverviewSection(tagline: tv.tagline, overview: tv.overview)
        GenreChipsRow(names: hero.genreNames)
        MetadataRow(items: tv.metadataItems)
        CreditLine(label: "Created by", names: tv.creatorNames)
        EpisodeSection(title: "Next Episode", episode: tv.nextEpisodeToAir)
        EpisodeSection(title: "Last Episode", episode: tv.lastEpisodeToAir)
        CastSection(cast: tv.cast)
        SeasonsSection(seasons: tv.seasons)
    }

    @ViewBuilder
    private func personSections(_ person: PersonDetail) -> some View {
        BiographySection(biography: person.biography)
        SectionView(title: "Known For",
                    description: "Most popular credits.",
                    data: viewModel.knownFor)
    }
}

#Preview("Movie") {
    NavigationStack {
        DetailView(id: 693134, mediaType: .movie)
    }
}

#Preview("TV") {
    NavigationStack {
        DetailView(id: 100088, mediaType: .tv)
    }
}

#Preview("Person") {
    NavigationStack {
        DetailView(id: 1356210, mediaType: .person)
    }
}

#Preview("Invalid ID") {
    NavigationStack {
        DetailView(id: 1353344343, mediaType: .movie)
    }
}
