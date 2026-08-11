//
//  LibraryButton.swift
//  MovieMind
//
//  Created by Semih Söğüt on 7.07.2026.
//

import SwiftUI
import SwiftData

struct LibraryButton: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var savedItems: [LibraryItem]

    private let mediaId: Int
    private let mediaType: MediaType
    private let displayName: String
    private let posterPath: String?
    private let diameter: CGFloat
    private let showsBackground: Bool
    private var isSaved: Bool { !savedItems.isEmpty }

    init(mediaId: Int,
         mediaType: MediaType,
         displayName: String,
         posterPath: String?,
         diameter: CGFloat = 45,
         showsBackground: Bool) {
        self.mediaId = mediaId
        self.mediaType = mediaType
        self.displayName = displayName
        self.posterPath = posterPath
        self.diameter = diameter
        self.showsBackground = showsBackground

        let key = LibraryItem.key(id: mediaId, mediaType: mediaType)
        var descriptor = FetchDescriptor<LibraryItem>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1
        _savedItems = Query(descriptor)
    }

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
        if let existing = savedItems.first {
            modelContext.delete(existing)
        } else {
            modelContext.insert(LibraryItem(
                mediaId: mediaId,
                mediaType: mediaType,
                displayName: displayName,
                posterPath: posterPath
            ))
        }
    }
}
