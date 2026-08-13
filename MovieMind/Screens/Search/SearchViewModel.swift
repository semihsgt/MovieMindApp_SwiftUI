//
//  SearchViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 30.06.2026.
//

import SwiftUI

@MainActor
@Observable
final class SearchViewModel {

    var searchText: String = ""
    private(set) var state: ViewState<[MediaItem]> = .idle
    private(set) var isLoadingMore: Bool = false

    private let networkService: SearchServicing
    private var currentPage = 1
    private var totalPages = 1
    private var activeQuery = ""

    init(networkService: SearchServicing = NetworkManager.shared) {
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
            state = .loaded(response.results.filter { $0.id != nil })
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(error)
        }
    }

    func loadMoreIfNeeded(currentItem: MediaItem) async {
        guard case .loaded(let items) = state,
              !isLoadingMore,
              currentPage < totalPages,
              let index = items.firstIndex(where: { $0.id == currentItem.id }),
              index >= items.count - 5 else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let query = activeQuery
        let nextPage = currentPage + 1

        do {
            let response = try await networkService.fetchSearch(
                for: .searchMulti(query: query, page: nextPage)
            )

            // A new search can start while this page is in flight. Cancelling the
            // row's task usually gets here first, but not once the response has
            // already landed — so re-read the state instead of trusting the copy.
            guard query == activeQuery,
                  case .loaded(let current) = state else { return }

            let existingIds = Set(current.compactMap(\.id))
            let newItems = response.results.filter {
                guard let id = $0.id else { return false }
                return !existingIds.contains(id)
            }

            currentPage = nextPage
            totalPages = response.totalPages ?? totalPages
            state = .loaded(current + newItems)
        } catch {
            // Keep the pages already loaded
        }
    }
}
