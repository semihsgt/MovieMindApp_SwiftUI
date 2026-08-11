//
//  CollectionViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 19.07.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CollectionViewModel {

    private(set) var state: ViewState<CollectionDetail> = .idle

    private let networkService: CollectionServicing
    private var loadedId: Int?

    init(networkService: CollectionServicing = NetworkManager.shared) {
        self.networkService = networkService
    }

    func loadIfNeeded(id: Int) async {
        guard id != loadedId else { return }
        loadedId = id
        await load(id: id)
    }

    func load(id: Int) async {
        state = .loading

        do {
            state = .loaded(try await networkService.fetchCollection(id: id))
        } catch {
            state = .failed(error)
        }
    }
}
