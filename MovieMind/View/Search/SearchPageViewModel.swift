//
//  SearchPageViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 30.06.2026.
//

import SwiftUI
internal import Combine

@MainActor
final class SearchViewModel: ObservableObject {

    private let networkService: NetworkServicing

    @Published var searchText: String = ""
    @Published private(set) var state: ViewState<[MediaItem]> = .idle
    @Published private(set) var isLoadingMore: Bool = false

    private var currentPage = 1
    private var totalPages = 1
    private var activeQuery = ""

    init(networkService: NetworkServicing = NetworkManager.shared) {
        self.networkService = networkService
    }

    func searchTextChanged() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            state = .idle
            activeQuery = ""
            return
        }

        do {
            try await Task.sleep(for: .milliseconds(500))
        } catch {
            return
        }

        guard query == searchText.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

        await performSearch(query: query)
    }

    func retry() async {
        guard !activeQuery.isEmpty else { return }
        await performSearch(query: activeQuery)
    }

    private func performSearch(query: String) async {
        state = .loading
        activeQuery = query
        currentPage = 1

        do {
            let response = try await networkService.fetchSearch(for: .searchMulti(query: query, page: 1))
            guard !Task.isCancelled else { return }
            totalPages = response.totalPages ?? 1
            state = .loaded((response.results ?? []).filter { $0.id != nil })
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(error.localizedDescription)
        }
    }

    func loadMoreIfNeeded(currentItem: MediaItem) async {
        guard case .loaded(var items) = state,
              !isLoadingMore,
              currentPage < totalPages,
              let index = items.firstIndex(where: { $0.id == currentItem.id }),
              index >= items.count - 5 else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let response = try await networkService.fetchSearch(
                for: .searchMulti(query: activeQuery, page: nextPage)
            )
            currentPage = nextPage
            totalPages = response.totalPages ?? totalPages

            let existingIds = Set(items.compactMap(\.id))
            let newItems = (response.results ?? []).filter {
                guard let id = $0.id else { return false }
                return !existingIds.contains(id)
            }
            items.append(contentsOf: newItems)
            state = .loaded(items)
        } catch {
            // Keep current pages
        }
    }
}
