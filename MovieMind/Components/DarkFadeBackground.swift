//
//  DarkFadeBackground.swift
//  MovieMind
//
//  Created by Semih Söğüt on 12.08.2026.
//

import SwiftUI

/// Fades the hero image into the black content area below it.
private struct DarkFadeBackground: ViewModifier {

    func body(content: Content) -> some View {
        content.background(alignment: .top) {
            LinearGradient(
                colors: [.black.opacity(0.7), .black, .black, .black, .black, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.horizontal, -30)
            .padding(.bottom, -30)
            .blur(radius: 10)
        }
    }
}

extension View {
    func darkFadeBackground() -> some View {
        modifier(DarkFadeBackground())
    }
}
