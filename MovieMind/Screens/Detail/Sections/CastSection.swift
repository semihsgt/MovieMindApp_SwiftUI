//
//  CastSection.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

struct CastSection: View {

    let cast: [CastMember]

    var body: some View {
        if !cast.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Cast")
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(cast.prefix(15), id: \.uniqueId) { member in
                            if let personId = member.id {
                                memberCard(member, personId: personId)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func memberCard(_ member: CastMember, personId: Int) -> some View {
        let route = MediaRoute(id: personId, mediaType: .person)

        return NavigationLink(value: route) {
            VStack(spacing: 4) {
                AsyncPoster(path: member.profilePath,
                            width: 100, height: 150,
                            size: .w200)

                Text(member.name)
                    .font(.caption.bold())
                    .lineLimit(1)

                Text(member.character)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }
            .frame(width: 100)
            .foregroundStyle(.white)
        }
        .zoomSource(id: route)
    }
}

#Preview("Cast") {
    NavigationStack {
        CastSection(cast: CastMember.previews)
            .frame(height: 300)
    }
}

#Preview("Empty") {
    CastSection(cast: [])
}
