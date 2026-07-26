//
//  WatchlistButton.swift
//  MovieMind
//
//  Created by Semih Söğüt on 7.07.2026.
//

import SwiftUI
import SwiftData

struct WatchlistButton: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var savedItems: [WatchlistItem]
    
    private let mediaId: Int
    private let mediaType: MediaType
    private let displayName: String
    private let posterPath: String?
    private let diameter: CGFloat
    private let showsBackground: Bool
    
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
        
        let key = WatchlistItem.key(id: mediaId, mediaType: mediaType)
        var descriptor = FetchDescriptor<WatchlistItem>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1
        _savedItems = Query(descriptor)
    }
    
    private var isSaved: Bool { !savedItems.isEmpty }
    
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
        .accessibilityLabel(isSaved ? "Remove from watchlist" : "Add to watchlist")
    }
    
    private func toggle() {
        if let existing = savedItems.first {
            modelContext.delete(existing)
        } else {
            modelContext.insert(WatchlistItem(
                mediaId: mediaId,
                mediaType: mediaType,
                displayName: displayName,
                posterPath: posterPath
            ))
        }
    }
}
