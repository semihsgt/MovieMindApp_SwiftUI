//
//  SearchRowView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 30.06.2026.
//

import SwiftUI

/// One search result: poster, title, rating and year.
struct SearchRowView: View {
    let item: MediaItem

    var body: some View {
        HStack(spacing: 14) {

            AsyncPoster(path: item.displayPath, width: 70, height: 105, cornerRadius: 12, size: .w200)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.displayName)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack {
                    if item.voteAverage > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)

                            Text(String(format: "%.1f", item.voteAverage))
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let year = item.displayDate?.releaseYear {
                        Text(year)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 5)

        }
        .padding(8)
        .background(Color(.secondarySystemBackground).opacity(0.5), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 12) {
        SearchRowView(item: HeroUIModel.previewMovie.result)
        SearchRowView(item: HeroUIModel.previewPerson.result)
    }
    .padding()
}
