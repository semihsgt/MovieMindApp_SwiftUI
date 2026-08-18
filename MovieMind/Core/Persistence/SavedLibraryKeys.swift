//
//  SavedLibraryKeys.swift
//  MovieMind
//
//  Created by Semih Söğüt on 13.08.2026.
//

import SwiftUI
import SwiftData

private struct SavedLibraryKeysKey: EnvironmentKey {
    static let defaultValue: Set<String> = []
}

extension EnvironmentValues {

    /// Keys of everything currently in the library, e.g. "movie-693134".
    var savedLibraryKeys: Set<String> {
        get { self[SavedLibraryKeysKey.self] }
        set { self[SavedLibraryKeysKey.self] = newValue }
    }
}

/// Runs the library query once for the whole app and publishes the result through
/// the environment. Without it every `LibraryButton` on screen opens its own
/// `@Query` — twenty poster cards meant twenty SwiftData fetches.
struct SavedLibraryKeysProvider<Content: View>: View {

    @Query private var items: [LibraryItem]
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .environment(\.savedLibraryKeys, Set(items.map(\.key)))
    }
}
