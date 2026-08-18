//
//  SearchView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct SearchView: View {
    
    @State private var viewModel = SearchViewModel()
    @Namespace private var zoomNamespace

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    ContentUnavailableView(
                        "Explore Movie Mind",
                        systemImage: "magnifyingglass",
                        description: Text("Search for movies, TV shows, or people.")
                    )

                case .loading:
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failed(let error):
                    ErrorRetryView(error: error) {
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
            .appDestinations(in: zoomNamespace)
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

                ForEach(items, id: \.uniqueId) { item in
                    if let route = MediaRoute(item: item) {
                        NavigationLink(value: route) {
                            SearchRowView(item: item)
                        }
                        .buttonStyle(.plain)
                        .zoomSource(id: route)
                        .accessibilityRepresentation {
                            Button(item.accessibilityLabel) {}
                        }
                        .task { await viewModel.loadMoreIfNeeded(currentItem: item) }
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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Ask AI for recommendations for \(trimmedQuery)")
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchView()
}
