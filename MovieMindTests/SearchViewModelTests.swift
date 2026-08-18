//
//  SearchViewModelTests.swift
//  MovieMindTests
//
//  Created by Semih Söğüt on 18.08.2026.
//

import Testing
import Foundation
@testable import MovieMind

/// `SearchServicing` is `Sendable`, so the mock is an actor rather than a class
/// with mutable state — Swift 6 rejects the latter.
private actor SearchServiceMock: SearchServicing {

    private let pages: [Int: ListRespond]
    private let failure: Error?
    private(set) var requestedPages: [Int] = []

    init(pages: [Int: ListRespond] = [:], failure: Error? = nil) {
        self.pages = pages
        self.failure = failure
    }

    func fetchSearch(for endpoint: SearchEndpoint) async throws -> ListRespond {
        guard case .searchMulti(_, let page) = endpoint else {
            return ListRespond(results: [], totalPages: 1)
        }
        requestedPages.append(page)
        if let failure { throw failure }
        return pages[page] ?? ListRespond(results: [], totalPages: 1)
    }
}

private func items(_ ids: [Int]) -> [MediaItem] {
    ids.map { MediaItem(id: $0, mediaType: .movie, title: "Movie \($0)") }
}

@Suite("SearchViewModel")
@MainActor
struct SearchViewModelTests {

    @Test("An empty query goes back to idle without a request")
    func emptyQueryIsIdle() async {
        let mock = SearchServiceMock()
        let sut = SearchViewModel(networkService: mock)

        sut.searchText = "   "
        await sut.searchTextChanged()

        if case .idle = sut.state {} else {
            Issue.record("Expected .idle, got \(sut.state)")
        }
        #expect(await mock.requestedPages.isEmpty)
    }

    @Test("A query loads the first page")
    func loadsFirstPage() async {
        let mock = SearchServiceMock(pages: [1: ListRespond(results: items([1, 2]), totalPages: 2)])
        let sut = SearchViewModel(networkService: mock)

        sut.searchText = "dune"
        await sut.searchTextChanged()

        #expect(sut.state.value?.count == 2)
        #expect(await mock.requestedPages == [1])
    }

    @Test("Paging appends and drops ids already on screen")
    func pagingDeduplicates() async throws {
        let mock = SearchServiceMock(pages: [
            1: ListRespond(results: items(Array(1...10)), totalPages: 2),
            2: ListRespond(results: items([10, 11, 12]), totalPages: 2)
        ])
        let sut = SearchViewModel(networkService: mock)

        sut.searchText = "dune"
        await sut.searchTextChanged()

        let last = try #require(sut.state.value?.last)
        await sut.loadMoreIfNeeded(currentItem: last)

        let ids = sut.state.value?.compactMap(\.id)
        #expect(ids == Array(1...12))
    }

    @Test("A failure surfaces as .failed")
    func failureSurfaces() async {
        let mock = SearchServiceMock(failure: NetworkError.notFound)
        let sut = SearchViewModel(networkService: mock)

        sut.searchText = "dune"
        await sut.searchTextChanged()

        if case .failed = sut.state {} else {
            Issue.record("Expected .failed, got \(sut.state)")
        }
    }
}
