//
//  CollectionBanner.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

/// Entry point to the collection a movie belongs to.
struct CollectionBanner: View {

    let collection: BelongsToCollection

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncPoster(path: collection.backdropPath,
                        height: 120,
                        cornerRadius: 20)

            LinearGradient(colors: [.clear, .black.opacity(0.8)],
                           startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(collection.displayName)
                .font(.headline.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .padding(12)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CollectionBanner(collection: .preview)
        .frame(height: 120)
}
