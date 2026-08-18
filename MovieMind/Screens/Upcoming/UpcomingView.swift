//
//  UpcomingView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct UpcomingView: View {

    @State private var viewModel = UpcomingViewModel()
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            ScrollView {
                StateContainerView(state: viewModel.state) {
                    await viewModel.load()
                } loading: {
                    UpcomingSkeletonView()
                } content: { items in
                    upcomingContent(items)
                }
                .padding(.vertical)
            }
            .navigationTitle("Upcoming Media")
            .appDestinations(in: zoomNamespace)
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
                ForEach(items, id: \.uniqueId) { item in
                    let route = MediaRoute(id: item.id, mediaType: item.mediaType)
                    NavigationLink(value: route) {
                        UpcomingCard(item: item)
                    }
                    .zoomSource(id: route)
                    // Art, overlapping text and a chevron in one stack: VoiceOver
                    // gets a plain button rather than the layout.
                    .accessibilityRepresentation {
                        Button(item.accessibilityLabel) {}
                    }
                }
            }
        }
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
                            size: .w500)
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

                    Text(item.result.displayDate?.toDate()?.relativeReleaseString()
                         ?? "Release date unknown")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))

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
    UpcomingView()
}
