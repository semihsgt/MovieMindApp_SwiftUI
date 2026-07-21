//
//  LibraryPageView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI
import SwiftData

private let recentlyAddedDescriptor: FetchDescriptor<WatchlistItem> = {
    var descriptor = FetchDescriptor<WatchlistItem>(
        sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
    )
    descriptor.fetchLimit = 12
    return descriptor
}()

struct LibraryPageView: View {

    @Query(recentlyAddedDescriptor)
    private var items: [WatchlistItem]

    @Namespace private var zoomNamespace

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    List {
                        LibraryRow(icon: "bookmark.fill", title: "All Saved", iconColor: .red, route: .all)
                        LibraryRow(icon: "film", title: "Movies", iconColor: .blue, route: .category(.movie))
                        LibraryRow(icon: "tv", title: "TV Shows", iconColor: .blue, route: .category(.tv))
                        LibraryRow(icon: "person.crop.rectangle", title: "People", iconColor: .blue, route: .category(.person))
                    }
                    .listStyle(.plain)
                    .frame(height: 290)
                    .scrollDisabled(true)
                    
                    Text("Recently Added")
                        .font(.title2.bold())
                        .fontDesign(.rounded)
                        .padding()
                    
                    recentlyAddedRail
                }
            }
            .navigationTitle("Library")
            .navigationDestination(for: MediaRoute.self) { route in
                DetailPageView(id: route.id, mediaType: route.mediaType)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
            .navigationDestination(for: LibraryRoute.self) { route in
                WatchlistListView(filter: route.filter, title: route.title)
            }
            .navigationDestination(for: CollectionRoute.self) { route in
                CollectionPageView(route: route)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
        }
        .zoomNamespace(zoomNamespace)
    }
    
    @ViewBuilder
    private var recentlyAddedRail: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "Nothing Saved Yet",
                systemImage: "bookmark",
                description: Text("Tap + on any title to add it to your library.")
            )
            .padding(.top, 40)
        } else {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    let route = MediaRoute(id: item.mediaId, mediaType: item.mediaType)
                    NavigationLink(value: route) {
                        AsyncPoster(path: item.posterPath,
                                    width: nil, height: 180,
                                    size: .w500)
                    }
                    .buttonStyle(.plain)
                    .zoomSource(id: route)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}


struct WatchlistListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [WatchlistItem]
    let title: String
    
    init(filter: MediaType?, title: String) {
        self.title = title
        if let raw = filter?.rawValue {
            _items = Query(
                filter: #Predicate<WatchlistItem> { $0.mediaTypeRaw == raw },
                sort: \WatchlistItem.dateAdded,
                order: .reverse
            )
        } else {
            _items = Query(sort: \WatchlistItem.dateAdded, order: .reverse)
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
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}


struct LibraryRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    let route: LibraryRoute
    
    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(iconColor)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    LibraryPageView()
        .modelContainer(for: WatchlistItem.self, inMemory: true)
}
