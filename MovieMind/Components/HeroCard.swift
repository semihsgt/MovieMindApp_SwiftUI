//
//  HeroCard.swift
//  MovieMind
//
//  Created by Semih Söğüt on 4.07.2026.
//

import SwiftUI
import Nuke
import NukeUI

struct HeroCard: View {
    
    let item: HeroUIModel
    let isButtonDisplayed: Bool
    
    private var mediaType: MediaType? { item.result.mediaType }
    private var posterPath: String? { item.images?.bestPoster ?? item.result.displayPath }
    private var logoPath: String? { item.images?.bestLogo() }
    
    private var logoMaxWidth: CGFloat { isButtonDisplayed ? 260 : 350 }
    private var logoMaxHeight: CGFloat { isButtonDisplayed ? 90 : 120 }
    
    private var mediaTypeLabel: String {
        switch mediaType {
        case .person: return "Person"
        case .tv: return "TV"
        case .movie: return "Movie"
        case .none: return ""
        }
    }

    init(item: HeroUIModel, isButtonDisplayed: Bool = true) {
        self.item = item
        self.isButtonDisplayed = isButtonDisplayed
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .black.opacity(0.3),
                    .clear,
                    .clear,
                    .clear,
                    .black.opacity(0.3),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            if isButtonDisplayed {
                
                VStack(spacing: 0) {
                    Spacer()

                    titleView
                        .padding(.bottom, 8)

                    subtitleView
                        .shadow(radius: 10)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.bottom, 20)

                    actionButtonsView
                        .shadow(radius: 10)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                
            } else if mediaType != .person {
                
                VStack(spacing: 0) {
                    Spacer()
                    titleView
                        .padding(.vertical)
                }
                
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
        .background { backgroundImageView }
        .clipped()
    }

    @ViewBuilder
    private var backgroundImageView: some View {
        if let posterPath, !posterPath.isEmpty {
            AsyncPoster(path: posterPath, contentMode: .fill, cornerRadius: 0, size: .w780)
        } else {
            Rectangle().fill(Color.black.opacity(0.8))
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if let url = TMDBImage.url(for: logoPath, size: .w500) {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: logoMaxWidth, maxHeight: logoMaxHeight)
                        .shadow(radius: 10)
                } else if state.error != nil {
                    fallbackTitleView
                }
            }
            .pipeline(.shared)
        } else {
            fallbackTitleView
        }
    }

    private var fallbackTitleView: some View {
        Text(item.result.displayName)
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .shadow(radius: 4, x: 0, y: 2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 25)
    }

    @ViewBuilder
    private var subtitleView: some View {
        switch mediaType {
        case .person:
            HStack(spacing: 6) {
                Text(mediaTypeLabel)

                if let department = item.result.knownForDepartment {
                    Text("•")
                    Text(department)
                }

                if let topKnown = item.result.knownFor.first {
                    let topTitle = topKnown.displayName
                    if !topTitle.isEmpty {
                        Text("•")
                        Text("Known for \(topTitle)")
                            .lineLimit(1)
                    }
                }
            }

        case .tv, .movie:
            HStack(spacing: 6) {
                Text(mediaTypeLabel)

                ForEach(Array(item.genreNames.prefix(2)), id: \.self) { genreName in
                    Text("•")
                    Text(genreName)
                }

                if item.result.adult {
                    Text("•")
                    Text("18+")
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                }
            }

        case .none:
            EmptyView()
        }
    }

    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            NavigationLink(value: MediaRoute(id: item.id, mediaType: mediaType ?? .movie)) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("More Info")
                        .fontWeight(.medium)
                }
                .frame(width: 150, height: 45)
                .foregroundStyle(.black)
                .background(.white, in: .capsule)
            }

            LibraryButton(
                mediaId: item.id,
                mediaType: mediaType ?? .movie,
                displayName: item.result.displayName,
                posterPath: item.result.displayPath,
                showsBackground: true
            )
        }
    }
}

#Preview("Home Page") {
    HomeView()
}

#Preview("Hero Cards") {
    TabView {
        HeroCard(item: .previewMovie)
        HeroCard(item: .previewTV)
        HeroCard(item: .previewPerson)
    }
    .tabViewStyle(.page(indexDisplayMode: .always))
    .ignoresSafeArea()
}
