//
//  AsyncPosterView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 29.06.2026.
//

import SwiftUI
import UIKit
import Nuke
import NukeUI

struct AsyncPoster: View {
    let path: String?
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 16
    var size: TMDBImage.Size = .w500

    private static let maxRetries = 2
    @State private var failedAttempts = 0

    private var url: URL? {
        TMDBImage.url(for: path, size: size)
    }

    private var request: ImageRequest? {
        guard let url else { return nil }

        let targetSize = CGSize(
            width: width ?? UIScreen.main.bounds.width,
            height: height ?? UIScreen.main.bounds.height
        )
        let resizeMode: ImageProcessingOptions.ContentMode = contentMode == .fill ? .aspectFill : .aspectFit
        let processors: [any ImageProcessing] = [
            ImageProcessors.Resize(size: targetSize, unit: .points, contentMode: resizeMode)
        ]

        return ImageRequest(url: url, processors: processors)
    }

    var body: some View {
        Group {
            if let request {
                LazyImage(request: request) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    } else if state.error != nil {
                        placeholderView
                            .task { await retryIfPossible() }
                    } else {
                        ProgressView()
                    }
                }
                .pipeline(.shared)
                .id(failedAttempts)
            } else {
                placeholderView
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onChange(of: path) {
            if failedAttempts != 0 { failedAttempts = 0 }
        }
    }

    private func retryIfPossible() async {
        guard failedAttempts < Self.maxRetries else { return }
        let nextAttempt = failedAttempts + 1
        try? await Task.sleep(for: .seconds(Double(nextAttempt) * 1.2))
        guard !Task.isCancelled else { return }
        failedAttempts = nextAttempt
    }

    private var placeholderView: some View {
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
    HomePageView()
}
