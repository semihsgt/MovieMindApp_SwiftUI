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

    @State private var retryCount = 0
    @State private var reloadToken = UUID()

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
                            .task {
                                await retryIfPossible()
                            }
                    } else {
                        ProgressView()
                    }
                }
                .pipeline(.shared)
                .id(reloadToken)
            } else {
                placeholderView
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onChange(of: path) {
            retryCount = 0
            reloadToken = UUID()
        }
    }

    private func retryIfPossible() async {
        guard retryCount < Self.maxRetries else { return }
        retryCount += 1
        try? await Task.sleep(for: .seconds(Double(retryCount) * 1.2))
        guard !Task.isCancelled else { return }
        reloadToken = UUID()
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
