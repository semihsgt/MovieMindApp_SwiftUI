//
//  WatchProvidersSection.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

struct WatchProvidersSection: View {

    let providers: CountryWatchProviders?

    /// One logo per provider: the same service shows up under flatrate, rent and buy.
    private var uniqueProviders: [WatchProvider] {
        var seen = Set<Int>()
        return (providers?.all ?? [])
            .filter { provider in
                guard let id = provider.providerId else { return false }
                return seen.insert(id).inserted
            }
            .sorted { ($0.displayPriority ?? .max) < ($1.displayPriority ?? .max) }
    }

    var body: some View {
        if !uniqueProviders.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Where to Watch")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(uniqueProviders) { provider in
                            AsyncPoster(path: provider.logoPath,
                                        width: 50, height: 50,
                                        cornerRadius: 12,
                                        size: .w200)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}

#Preview("Providers") {
    WatchProvidersSection(providers: .preview)
}

#Preview("None") {
    WatchProvidersSection(providers: nil)
}
