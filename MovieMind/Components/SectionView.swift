//
//  SectionView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import SwiftUI

/// A titled horizontal poster rail, optionally with a Movie/TV picker in its header.
struct SectionView: View {

    let title: String
    let description: String
    let data: [MediaItem]
    @Binding var mediaType: MediaTypeForPicker?

    init(title: String,
         description: String,
         data: [MediaItem],
         mediaType: Binding<MediaTypeForPicker?> = .constant(nil)) {
        self.title = title
        self.description = description
        self.data = data
        self._mediaType = mediaType
    }

    var body: some View {
        if !data.isEmpty {
            VStack {
                header
                posterRail
            }
            .padding(.bottom, 40)
        }
    }

    private var header: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title3.bold())
                    .fontDesign(.rounded)

                Spacer()

                if mediaType != nil {
                    Picker("", selection: $mediaType) {
                        ForEach(MediaTypeForPicker.allCases) { item in
                            Text(item.rawValue)
                                .tag(item as MediaTypeForPicker?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
            }

            HStack {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)

                Spacer()
            }
        }
        .padding(.horizontal)
    }

    private var posterRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(Array(data.enumerated()), id: \.element.uniqueId) { index, item in
                    if let route = MediaRoute(item: item, sourceKey: title) {
                        NavigationLink(value: route) {
                            poster(for: item)
                        }
                        .zoomSource(id: route)
                        .accessibilityRepresentation {
                            Button(item.accessibilityLabel) {}
                        }
                        .accessibilityHint(index == 0 ? AccessibilityHint.horizontalRail : "")
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func poster(for item: MediaItem) -> some View {
        VStack {
            AsyncPoster(path: item.displayPath, width: 100, height: 150)

            // People are the only rail where the name isn't already on the artwork.
            if item.mediaType == .person {
                VStack {
                    Text(item.displayName)
                        .font(.caption)

                    Text(item.knownForDepartment ?? "")
                        .font(.caption2)
                }
                .foregroundStyle(.white)
                .frame(width: 100, height: 30)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            SectionView(title: "Popular",
                        description: "What everyone is watching right now.",
                        data: [HeroUIModel.previewMovie.result,
                               HeroUIModel.previewTV.result])

            SectionView(title: "Trending People",
                        description: "Most searched stars and creators this week.",
                        data: [HeroUIModel.previewPerson.result])
        }
    }
}
