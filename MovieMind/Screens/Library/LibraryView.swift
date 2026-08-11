//
//  LibraryView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI
import SwiftData

private let recentlyAddedDescriptor: FetchDescriptor<LibraryItem> = {
    var descriptor = FetchDescriptor<LibraryItem>(
        sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
    )
    descriptor.fetchLimit = 12
    return descriptor
}()

struct LibraryView: View {

    @Query(recentlyAddedDescriptor) private var items: [LibraryItem]
    @Namespace private var zoomNamespace

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    categoryList

                    Text("Recently Added")
                        .font(.title2.bold())
                        .fontDesign(.rounded)
                        .padding()

                    recentlyAddedRail
                }
            }
            .navigationTitle("Library")
            .navigationDestination(for: MediaRoute.self) { route in
                DetailView(id: route.id, mediaType: route.mediaType)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
            .navigationDestination(for: LibraryRoute.self) { route in
                LibraryListView(filter: route.filter, title: route.title)
            }
            .navigationDestination(for: CollectionRoute.self) { route in
                CollectionView(route: route)
                    .zoomDestination(id: route, in: zoomNamespace)
            }
        }
        .zoomNamespace(zoomNamespace)
    }

    private var categoryList: some View {
        List {
            LibraryRow(icon: "bookmark.fill", iconColor: .red, route: .all)
            LibraryRow(icon: "film", iconColor: .blue, route: .category(.movie))
            LibraryRow(icon: "tv", iconColor: .blue, route: .category(.tv))
            LibraryRow(icon: "person.crop.rectangle", iconColor: .blue, route: .category(.person))
        }
        .listStyle(.plain)
        .frame(height: 290)
        .scrollDisabled(true)
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

#Preview {
    LibraryView()
        .modelContainer(for: LibraryItem.self, inMemory: true)
}
