//
//  LibraryListView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI
import SwiftData

struct LibraryListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [LibraryItem]

    let title: String

    init(filter: MediaType?, title: String) {
        self.title = title

        if let raw = filter?.rawValue {
            _items = Query(
                filter: #Predicate<LibraryItem> { $0.mediaTypeRaw == raw },
                sort: \LibraryItem.dateAdded,
                order: .reverse
            )
        } else {
            _items = Query(sort: \LibraryItem.dateAdded, order: .reverse)
        }
    }

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView(
                    "Nothing Here Yet",
                    systemImage: "bookmark",
                    description: Text("Saved items of this type will appear here.")
                )
            } else {
                List {
                    ForEach(items) { item in
                        let route = MediaRoute(id: item.mediaId, mediaType: item.mediaType)
                        NavigationLink(value: route) {
                            row(for: item)
                        }
                        .zoomSource(id: route)
                    }
                    .onDelete(perform: delete)
                    .listSectionSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(for item: LibraryItem) -> some View {
        HStack(spacing: 12) {
            AsyncPoster(path: item.posterPath,
                        width: 50, height: 75,
                        cornerRadius: 8,
                        size: .w200)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.headline)

                Text(item.dateAdded.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
