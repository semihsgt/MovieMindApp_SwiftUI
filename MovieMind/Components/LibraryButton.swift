//
//  LibraryButton.swift
//  MovieMind
//
//  Created by Semih Söğüt on 7.07.2026.
//

import SwiftUI
import SwiftData

/// Adds or removes one title from the library.
///
/// Membership is read from `savedLibraryKeys`, a single query shared by every
/// button on screen; the store is only touched when the button is tapped.
struct LibraryButton: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.savedLibraryKeys) private var savedKeys

    let mediaId: Int
    let mediaType: MediaType
    let displayName: String
    let posterPath: String?
    var diameter: CGFloat = 45
    let showsBackground: Bool

    private var key: String { LibraryItem.key(id: mediaId, mediaType: mediaType) }
    private var isSaved: Bool { savedKeys.contains(key) }

    var body: some View {
        Button {
            withAnimation(.snappy) { toggle() }
        } label: {
            Image(systemName: isSaved ? "checkmark" : "plus")
                .font(.system(size: diameter * 0.4, weight: .semibold))
                .frame(width: diameter, height: diameter)
                .foregroundStyle(.white)
                .background {
                    if showsBackground {
                        Circle().fill(.white.tertiary)
                    }
                }
        }
        .sensoryFeedback(.success, trigger: isSaved)
        .accessibilityLabel(isSaved ? "Remove from library" : "Add to library")
    }

    private func toggle() {
        if isSaved {
            removeSaved()
        } else {
            modelContext.insert(LibraryItem(mediaId: mediaId,
                                            mediaType: mediaType,
                                            displayName: displayName,
                                            posterPath: posterPath))
        }
    }

    private func removeSaved() {
        let key = key
        var descriptor = FetchDescriptor<LibraryItem>(predicate: #Predicate { $0.key == key })
        descriptor.fetchLimit = 1

        guard let existing = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(existing)
    }
}
