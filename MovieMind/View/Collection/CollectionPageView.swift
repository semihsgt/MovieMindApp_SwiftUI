//
//  CollectionPageView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 7.07.2026.
//

import Foundation
import SwiftUI

struct CollectionPageView: View {
    @StateObject private var viewModel = CollectionViewModel()
    let route: CollectionRoute
    
    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
    
    var body: some View {
        StateContainerView(state: viewModel.state) {
            await viewModel.load(id: route.id)
        } content: { detail in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    if let overview = detail.overview, !overview.isEmpty {
                        Text(overview)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(sortedParts(detail)) { item in
                            if let mediaRoute = MediaRoute(item: item) {
                                NavigationLink(value: mediaRoute) {
                                    AsyncPoster(path: item.displayPath,
                                                width: 110, height: 165,
                                                size: .w200)
                                }
                                .buttonStyle(.plain)
                                .zoomSource(id: mediaRoute)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(route.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: route.id) {
            await viewModel.loadIfNeeded(id: route.id)
        }
    }
    
    private func sortedParts(_ detail: CollectionDetail) -> [MediaItem] {
        (detail.parts ?? []).map { item -> MediaItem in
            var copy = item
            copy.mediaType = .movie
            return copy
        }
        .sorted {
            guard let a = $0.releaseDate, !a.isEmpty else { return false }
            guard let b = $1.releaseDate, !b.isEmpty else { return true }
            return a < b
        }
    }
}
