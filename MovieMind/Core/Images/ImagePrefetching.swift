//
//  ImagePrefetching.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation
import Nuke

/// Warms the disk cache only; decoding happens on screen, in `AsyncPoster`.
final class ImagePrefetching: @unchecked Sendable {

    static let shared = ImagePrefetching()
    private let prefetcher = Nuke.ImagePrefetcher(destination: .diskCache)

    init() {}

    /// Fire and forget: Nuke queues the downloads and returns immediately.
    private func prefetch(_ urls: [URL]) {
        prefetcher.startPrefetching(with: Array(Set(urls)))
    }

    func prefetch(_ paths: [String?], size: TMDBImage.Size) {
        prefetch(paths.compactMap { TMDBImage.url(for: $0, size: size) })
    }

    func cancelAll() {
        prefetcher.stopPrefetching()
    }
}
