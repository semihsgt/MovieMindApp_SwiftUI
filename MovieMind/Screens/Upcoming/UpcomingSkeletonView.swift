//
//  UpcomingSkeletonView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 12.08.2026.
//

import SwiftUI

/// Placeholder shown while the upcoming lists are loading.
struct UpcomingSkeletonView: View {

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                cardSkeleton
            }
        }
    }

    private var cardSkeleton: some View {
        ZStack {
            SkeletonBox(cornerRadius: 28)

            HStack(spacing: 12) {
                SkeletonBox(width: 100, height: 150, opacity: 0.12)
                    .padding(.leading)

                VStack(alignment: .leading, spacing: 10) {
                    SkeletonBox(width: 160, height: 16, cornerRadius: 4, opacity: 0.12)
                    SkeletonBox(width: 100, height: 12, cornerRadius: 4, opacity: 0.12)
                    SkeletonBox(width: 130, height: 12, cornerRadius: 4, opacity: 0.12)
                }
                .padding(.vertical, 20)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.horizontal, 15)
    }
}

#Preview {
    ScrollView {
        UpcomingSkeletonView()
    }
}
