//
//  SectionView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import SwiftUI

struct SectionView: View {
    let title: String
    let description: String
    let data: [MediaItem]?
    @Binding var mediaType: MediaTypeForPicker?
    
    init(title: String, description: String, data: [MediaItem]?, mediaType: Binding<MediaTypeForPicker?> = .constant(nil)) {
        self.title = title
        self.description = description
        self.data = data
        self._mediaType = mediaType
    }
    
    var body: some View {
        if let data = self.data {
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
                .padding(.horizontal)
                
                HStack {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(data) { item in
                            if let route = MediaRoute(item: item, sourceKey: title) {
                                NavigationLink(value: route) {
                                    VStack {
                                        AsyncPoster(path: item.displayPath, width: 100, height: 150)
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
                                .zoomSource(id: route)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 40)
        } else {
            EmptyView()
        }
    }
    
}

#Preview {
    HomePageView()
}
