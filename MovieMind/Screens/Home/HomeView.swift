//
//  HomeView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI
import SwiftData
import FluidHeader

private let recommendationSeedDescriptor: FetchDescriptor<LibraryItem> = {
    var descriptor = FetchDescriptor<LibraryItem>(
        sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
    )
    descriptor.fetchLimit = 20
    return descriptor
}()

struct HomeView: View {
    
    @State private var viewModel = HomeViewModel()
    @State private var recommendations = HomeRecommendationsViewModel()
    @Namespace private var zoomNamespace

    @Query(recommendationSeedDescriptor) private var library: [LibraryItem]

    private var librarySeeds: [LibrarySeed] {
        library.map { LibrarySeed(title: $0.displayName, mediaType: $0.mediaType) }
    }

    private var seedSignature: String {
        library.map(\.key).joined(separator: ",")
    }

    var body: some View {
        NavigationStack {
            StateContainerView(state: viewModel.state) {
                await viewModel.load()
            } loading: {
                HomeSkeletonView()
            } content: { heroItems in
                homeContent(heroItems)
            }
            .navigationTitle("Home")
            .appDestinations(in: zoomNamespace)
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .zoomNamespace(zoomNamespace)
        .task { await viewModel.loadIfNeeded() }
        .task(id: seedSignature) { await recommendations.load(seeds: librarySeeds) }
        .task(id: viewModel.trendingType) { await viewModel.refetchSection(.trending) }
        .task(id: viewModel.topRatedType) { await viewModel.refetchSection(.topRated) }
        .task(id: viewModel.popularType) { await viewModel.refetchSection(.popular) }
    }

    private func homeContent(_ heroItems: [HeroUIModel]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                FluidHeader {
                    TabView {
                        ForEach(heroItems) { item in
                            HeroCard(item: item)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .aspectRatio(2/3, contentMode: .fit)
                    .ignoresSafeArea()
                }
                .fluidHeaderBlurOffset(220)
                .fluidHeaderBlurHeight(40)
                .fluidHeaderOpacityHeight(300)

                sections
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var sections: some View {
        Group {

            if !recommendations.items.isEmpty {
                SectionView(title: "For You",
                            description: "AI picks based on your library.",
                            data: recommendations.items)
            } else if let notice = recommendations.noticeMessage {
                AINoticeBanner(message: notice)
            }

            SectionView(title: "Popular",
                        description: "What everyone is watching right now.",
                        data: viewModel.popularMT?.results ?? [],
                        mediaType: $viewModel.popularType)

            SectionView(title: "Trending",
                        description: "The hottest titles today.",
                        data: viewModel.trendingMT?.results ?? [],
                        mediaType: $viewModel.trendingType)

            SectionView(title: "Top Rated",
                        description: "Highly acclaimed movies and shows.",
                        data: viewModel.topRatedMT?.results ?? [],
                        mediaType: $viewModel.topRatedType)

            AIShortcutCard()
                .padding(.horizontal)
                .padding(.bottom, 40)

            SectionView(title: "Airing Today",
                        description: "Fresh TV episodes dropping today.",
                        data: viewModel.airingT?.results ?? [])

            SectionView(title: "In Theatres",
                        description: "New movies playing near you right now.",
                        data: viewModel.nowPlayingM?.results ?? [])

            SectionView(title: "Trending People",
                        description: "Most searched stars and creators this week.",
                        data: viewModel.popularP?.results ?? [])
        }
        .darkFadeBackground()
    }

}

#Preview {
    HomeView()
        .modelContainer(for: LibraryItem.self, inMemory: true)
}
