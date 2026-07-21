//
//  UpcomingPageView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct UpcomingPageView: View {
    @StateObject private var viewModel = UpcomingPageViewModel()
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            ScrollView {
                StateContainerView(state: viewModel.state) {
                    await viewModel.load()
                } loading: {
                    skeletonView
                } content: { items in
                    upcomingContent(items)
                }
                .padding(.vertical)
            }
            .navigationTitle("Upcoming Media")
            .navigationDestination(for: MediaRoute.self) { route in
                DetailPageView(id: route.id, mediaType: route.mediaType)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
            .navigationDestination(for: CollectionRoute.self) { route in
                CollectionPageView(route: route)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
        }
        .zoomNamespace(zoomNamespace)
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private func upcomingContent(_ items: [UpcomingUIModel]) -> some View {
        VStack(spacing: 16) {
            if items.isEmpty {
                ContentUnavailableView("Nothing Upcoming", systemImage: "popcorn")
                    .padding(.top, 40)
            } else {
                ForEach(items) { item in
                    let route = MediaRoute(id: item.id, mediaType: item.mediaType)
                    NavigationLink(value: route) {
                        UpcomingCard(item: item)
                    }
                    .zoomSource(id: route)
                }
            }
        }
    }

    var skeletonView: some View {
        VStack(spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                upcomingCardSkeleton
            }
        }
    }

    private var upcomingCardSkeleton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.08))
                .shimmer()

            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 100, height: 150)
                    .shimmer()
                    .padding(.leading)

                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 160, height: 16)
                        .shimmer()

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 100, height: 12)
                        .shimmer()

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 130, height: 12)
                        .shimmer()
                }
                .padding(.vertical, 20)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.horizontal, 15)
    }
}

private struct UpcomingCard: View {
    let item: UpcomingUIModel
    
    var body: some View {
        ZStack {
            AsyncPoster(path: item.result.displayPath,
                        height: 180,
                        cornerRadius: 28)
            .blur(radius: 20)
            .overlay(Color.black.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            
            HStack(spacing: 12) {
                AsyncPoster(path: item.result.displayPath,
                            width: 100, height: 150,
                            size: .w200)
                .padding(.leading)
                .shadow(radius: 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.result.displayName)
                        .font(.system(size: 18, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack(spacing: 6) {
                        let genres = Array(item.genreNames.prefix(2))
                        
                        ForEach(genres, id: \.self) { genre in
                            Text(genre)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                            
                            if genre != genres.last {
                                Text("•")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                    
                    if item.mediaType == .movie {
                        let formattedDate = item.result.releaseDate?.toDate()?.relativeReleaseString() ?? "Release date unknown"
                        
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                        
                    } else {
                        let formattedDate = item.result.firstAirDate?.toDate()?.relativeReleaseString() ?? "Release date unknown"
                        
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                }
                .fontDesign(.rounded)
                .padding(.vertical, 20)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .padding(.trailing, 20)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.horizontal, 15)
    }
}

#Preview {
    UpcomingPageView()
}

#Preview("Loading Skeleton") {
    UpcomingPageView().skeletonView
        .background(Color.black.ignoresSafeArea())
}
