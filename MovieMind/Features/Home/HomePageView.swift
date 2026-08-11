//
//  HomePageView.swift
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

struct HomePageView: View {
    
    @State private var viewModel = HomePageViewModel()
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
                skeletonView
            } content: { heroItems in
                homeContent(heroItems)
            }
            .navigationTitle("Home")
            .navigationDestination(for: MediaRoute.self) { route in
                DetailPageView(id: route.id, mediaType: route.mediaType)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
            .navigationDestination(for: CollectionRoute.self) { route in
                CollectionPageView(route: route)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
            .navigationDestination(for: AskAIRoute.self) { route in
                AskAIView(initialQuery: route.query)
            }
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

    private var skeletonView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                heroSkeleton

                VStack(spacing: 28) {
                    ForEach(0..<4, id: \.self) { _ in
                        sectionSkeleton
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var heroSkeleton: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .shimmer()
        }
        .aspectRatio(2.6/3, contentMode: .fit)
        .ignoresSafeArea(edges: .top)
    }

    private var sectionSkeleton: some View {
        VStack(alignment: .leading, spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 140, height: 18)
                    .shimmer()
                    .padding(.leading, 60)

            HStack(spacing: 10) {
                Spacer(minLength: 50)

                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 100, height: 150)
                        .shimmer()
                }
            }
        }
        .padding(.horizontal)

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
                        data: viewModel.popularMT?.results,
                        mediaType: $viewModel.popularType)

            SectionView(title: "Trending",
                        description: "The hottest titles today.",
                        data: viewModel.trendingMT?.results,
                        mediaType: $viewModel.trendingType)

            SectionView(title: "Top Rated",
                        description: "Highly acclaimed movies and shows.",
                        data: viewModel.topRatedMT?.results,
                        mediaType: $viewModel.topRatedType)

            AIShortcutCard()
                .padding(.horizontal)
                .padding(.bottom, 40)

            SectionView(title: "Airing Today",
                        description: "Fresh TV episodes dropping today.",
                        data: viewModel.airingT?.results)

            SectionView(title: "In Theatres",
                        description: "New movies playing near you right now.",
                        data: viewModel.nowPlayingM?.results)

            SectionView(title: "Trending People",
                        description: "Most searched stars and creators this week.",
                        data: viewModel.popularP?.results)
        }
        .background(alignment: .top) {
            LinearGradient(
                colors: [.black.opacity(0.7), .black, .black, .black, .black, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.horizontal, -30)
            .padding(.bottom, -30)
            .blur(radius: 10)
        }
    }

}

#Preview {
    HomePageView()
        .modelContainer(for: LibraryItem.self, inMemory: true)
}
