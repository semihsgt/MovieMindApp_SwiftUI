//
//  DetailSkeletonView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 12.08.2026.
//

import SwiftUI

/// Placeholder shown while the detail response is in flight.
struct DetailSkeletonView: View {

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroSkeleton

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        SkeletonBox(height: 14, cornerRadius: 4)
                        SkeletonBox(height: 14, cornerRadius: 4)
                        SkeletonBox(width: 180, height: 14, cornerRadius: 4)
                    }
                    .padding(.horizontal)

                    castRowSkeleton
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var heroSkeleton: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .shimmer()
            .aspectRatio(2/3, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)
    }

    private var castRowSkeleton: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonBox(width: 100, height: 150)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    DetailSkeletonView()
}
