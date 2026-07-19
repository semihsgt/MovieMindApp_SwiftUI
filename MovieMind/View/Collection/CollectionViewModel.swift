//
//  CollectionViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 19.07.2026.
//

import Foundation
internal import Combine

@MainActor
final class CollectionViewModel: ObservableObject {
    
    private let networkService: NetworkServicing
    
    @Published private(set) var state: ViewState<CollectionDetail> = .idle
    private var loadedId: Int?
    
    init(networkService: NetworkServicing = NetworkManager.shared) {
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
            let detail = try await networkService.fetchCollection(id: id)
            state = .loaded(detail)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
