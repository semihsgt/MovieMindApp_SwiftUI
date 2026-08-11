//
//  ChatBubble.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import SwiftUI

struct ChatBubble: View {
    
    let message: AskAIViewModel.Message

    var body: some View {
        switch message.role {
        case .user:
            HStack {
                Spacer(minLength: 40)
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.red, in: RoundedRectangle(cornerRadius: 18))
                    .foregroundStyle(.white)
            }

        case .assistant:
            VStack(alignment: .leading, spacing: 12) {
                Text(message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !message.items.isEmpty {
                    posterRail
                }
            }
        }
    }

    private var posterRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(message.items) { item in
                    if let route = MediaRoute(item: item, sourceKey: "ai-\(message.id)") {
                        NavigationLink(value: route) {
                            AsyncPoster(path: item.displayPath,
                                        width: 100, height: 150,
                                        size: .w200)
                        }
                        .buttonStyle(.plain)
                        .zoomSource(id: route)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}
