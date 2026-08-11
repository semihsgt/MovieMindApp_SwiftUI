//
//  HomeRecommendationsViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import Foundation
import SwiftUI

/// Owns the "For You" row: AI picks derived from the saved library.
@MainActor
@Observable
final class HomeRecommendationsViewModel {

    private(set) var items: [MediaItem] = []
    private(set) var failure: Error?

    private let recommender: AIRecommending
    private var lastSeedSignature: String?

    init(recommender: AIRecommending = AIRecommendationService.shared) {
        self.recommender = recommender
    }

    /// The error turned into display text, at the presentation boundary.
    var noticeMessage: String? {
        guard let failure else { return nil }
        return (failure as? AIError)?.errorDescription
            ?? "AI recommendations are unavailable right now."
    }

    func load(seeds: [LibrarySeed]) async {
        guard !seeds.isEmpty else {
            items = []
            failure = nil
            lastSeedSignature = nil
            return
        }

        let signature = seeds
            .map { "\($0.mediaType.rawValue):\($0.title)" }
            .sorted()
            .joined(separator: "|")
        guard signature != lastSeedSignature else { return }

        // Let rapid library edits settle before spending an AI call.
        do {
            try await Task.sleep(for: .seconds(2))
        } catch {
            return
        }

        lastSeedSignature = signature

        do {
            let result = try await recommender.recommend(from: seeds)
            guard !result.isEmpty else { return }

            failure = nil
            withAnimation(.easeInOut(duration: 0.4)) {
                items = result
            }
        } catch {
            failure = error
        }
    }
}
