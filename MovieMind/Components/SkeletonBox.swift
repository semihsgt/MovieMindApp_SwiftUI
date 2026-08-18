//
//  SkeletonBox.swift
//  MovieMind
//
//  Created by Semih Söğüt on 12.08.2026.
//

import SwiftUI

/// The single shimmering placeholder every loading skeleton is built from.
struct SkeletonBox: View {

    var width: CGFloat?
    var height: CGFloat?
    var cornerRadius: CGFloat = 16
    var opacity: Double = 0.08

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(opacity))
            .frame(width: width, height: height)
            .shimmer()
    }
}

#Preview {
    VStack(spacing: 20) {
        SkeletonBox(width: 100, height: 150)
        SkeletonBox(width: 180, height: 14, cornerRadius: 4)
    }
    .padding()
}
