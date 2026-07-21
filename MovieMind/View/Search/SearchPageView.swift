//
//  SearchPageView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct AskAIRoute: Hashable {
    let query: String
}

struct SearchPageView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    ContentUnavailableView(
                        "Explore MovieMind",
                        systemImage: "magnifyingglass",
                        description: Text("Search for movies, TV shows, or people.")
                    )

                case .loading:
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failed(let message):
                    ErrorRetryView(message: message) {
                        await viewModel.retry()
                    }

                case .loaded(let items):
                    if items.isEmpty {
                        emptyResultsView
                    } else {
                        resultsList(items)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Movies, TV Shows, People..."
            )
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
        }
        .zoomNamespace(zoomNamespace)
        .task(id: viewModel.searchText) {
            await viewModel.searchTextChanged()
        }
    }

    private var trimmedQuery: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @ViewBuilder
    private var emptyResultsView: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("No matches found. Ask AI for ideas instead.")
        } actions: {
            if !trimmedQuery.isEmpty {
                NavigationLink(value: AskAIRoute(query: trimmedQuery)) {
                    Label("Ask AI", systemImage: "sparkles")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func resultsList(_ items: [MediaItem]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if !trimmedQuery.isEmpty {
                    askAIRow
                }

                ForEach(items) { item in
                    if let route = MediaRoute(item: item) {
                        NavigationLink(value: route) {
                            SearchRowView(item: item)
                        }
                        .buttonStyle(.plain)
                        .zoomSource(id: route)
                        .task {
                            await viewModel.loadMoreIfNeeded(currentItem: item)
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
    }

    private var askAIRow: some View {
        NavigationLink(value: AskAIRoute(query: trimmedQuery)) {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.red)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ask AI")
                        .font(.headline)
                        .fontDesign(.rounded)

                    Text("Recommendations for “\(trimmedQuery)”")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 5)
            }
            .padding(8)
            .background(Color(.secondarySystemBackground).opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct SearchRowView: View {
    let item: MediaItem

    var body: some View {
        HStack(spacing: 14) {

            AsyncPoster(path: item.displayPath, width: 70, height: 105, cornerRadius: 12, size: .w200)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.displayName)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack {
                    if let voteAverage = item.voteAverage, voteAverage > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)

                            Text(String(format: "%.1f", voteAverage))
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let releaseDate = item.releaseDate?.prefix(4), !releaseDate.isEmpty {
                        Text(releaseDate)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    } else if let firstAirDate = item.firstAirDate?.prefix(4), !firstAirDate.isEmpty {
                        Text(firstAirDate)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 5)

        }
        .padding(8)
        .background(Color(.secondarySystemBackground).opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    SearchPageView()
}
