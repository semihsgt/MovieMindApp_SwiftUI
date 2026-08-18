//
//  AppDestinations.swift
//  MovieMind
//
//  Created by Semih Söğüt on 13.08.2026.
//

import SwiftUI

extension View {

    /// Registers every destination the shared components can push.
    ///
    /// Poster rails emit `MediaRoute`, collection banners emit `CollectionRoute` and
    /// the AI card emits `AskAIRoute` — and any of those components can be dropped
    /// onto any screen. Registering all three in one place means a rail keeps working
    /// wherever it is reused, instead of silently doing nothing on a stack that
    /// happened to only declare the routes it used at the time.
    func appDestinations(in namespace: Namespace.ID) -> some View {
        navigationDestination(for: MediaRoute.self) { route in
            DetailView(id: route.id, mediaType: route.mediaType)
                .zoomDestination(id: route, in: namespace)
        }
        .navigationDestination(for: CollectionRoute.self) { route in
            CollectionView(route: route)
                .zoomDestination(id: route, in: namespace)
        }
        .navigationDestination(for: AskAIRoute.self) { route in
            AskAIView(initialQuery: route.query)
        }
    }
}
