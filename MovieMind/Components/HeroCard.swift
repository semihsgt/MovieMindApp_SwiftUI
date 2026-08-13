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
        case .person: "Person"
        case .tv: "TV"
        case .movie: "Movie"
        case .none: ""
        }
    }
    
    /// TMDB's default poster usually has the title printed on the artwork, while the
    /// language-neutral one does not. Drawing the logo over the former would show the
    /// name twice, so it is only drawn when a textless poster was found — or for
    /// people, whose photos never carry a name.
    private var shouldShowTitle: Bool {
        mediaType == .person || posterPath != item.result.displayPath
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

                    if shouldShowTitle {
                        titleView
                            .padding(.bottom, 8)
                    }

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
                
            } else if shouldShowTitle {
                
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

    private var subtitleView: some View {
        DotSeparatedText(items: subtitleItems)
    }

    /// People read "Person • Acting • Known for …", titles read
    /// "Movie • Drama • Thriller • 18+".
    private var subtitleItems: [String] {
        switch mediaType {
        case .person:
            let known = item.result.knownFor.first?.displayName ?? ""
            return [mediaTypeLabel,
                    item.result.knownForDepartment,
                    known.isEmpty ? nil : "Known for \(known)"].compactMap { $0 }

        case .movie, .tv:
            return [mediaTypeLabel]
                + Array(item.genreNames.prefix(2))
                + (item.result.adult ? ["18+"] : [])

        case .none:
            return []
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
