//
//  SearchPageView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct SearchPageView: View {
    @StateObject private var viewModel = SearchViewModel()
    
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
                        ContentUnavailableView.search(text: viewModel.searchText)
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
            }
            .navigationDestination(for: CollectionRoute.self) { route in
                CollectionPageView(route: route)
            }
        }
        .task(id: viewModel.searchText) {
            await viewModel.searchTextChanged()
        }
    }
    
    private func resultsList(_ items: [MediaItem]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    if let route = MediaRoute(item: item) {
                        NavigationLink(value: route) {
                            SearchRowView(item: item)
                        }
                        .buttonStyle(.plain)
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
