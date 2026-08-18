//
//  AsyncPoster.swift
//  MovieMind
//
//  Created by Semih Söğüt on 29.06.2026.
//

import SwiftUI
import UIKit
import Nuke
import NukeUI

/// Every poster, profile photo and provider logo in the app.
///
/// Decodes at the size it is drawn at rather than the size it was downloaded at,
/// and retries a failed load twice with growing delays before giving up on the
/// placeholder.
struct AsyncPoster: View {
    
    let path: String?
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 16
    var size: TMDBImage.Size = .w500

    private static let maxRetries = 2
    @State private var failedAttempts = 0

    var body: some View {
        Group {
            if let request {
                LazyImage(request: request) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    } else if state.error != nil {
                        placeholder
                            .task { await retryIfPossible() }
                    } else {
                        ProgressView()
                    }
                }
                .pipeline(.shared)
                .id(failedAttempts)
            } else {
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onChange(of: path) {
            if failedAttempts != 0 { failedAttempts = 0 }
        }
        // Decoration: the row or card around the poster is what speaks.
        .accessibilityHidden(true)
    }
    
    private var request: ImageRequest? {
        guard let url = TMDBImage.url(for: path, size: size) else { return nil }

        let targetSize = CGSize(width: width ?? UIScreen.main.bounds.width,
                                height: height ?? UIScreen.main.bounds.height)
        let resizeMode: ImageProcessingOptions.ContentMode = contentMode == .fill ? .aspectFill : .aspectFit

        return ImageRequest(url: url,
                            processors: [ImageProcessors.Resize(size: targetSize, unit: .points, contentMode: resizeMode)])
    }

    private func retryIfPossible() async {
        guard failedAttempts < Self.maxRetries else { return }

        let nextAttempt = failedAttempts + 1
        try? await Task.sleep(for: .seconds(Double(nextAttempt) * 1.2))
        guard !Task.isCancelled else { return }
        failedAttempts = nextAttempt
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.25))

            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.25))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AsyncPoster(path: HeroUIModel.previewMovie.result.posterPath,
                    width: 120, height: 180)

        // No path: falls through to the placeholder.
        AsyncPoster(path: nil, width: 120, height: 180)
    }
    .padding()
}
