//
//  HomeSkeletonView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 12.08.2026.
//

import SwiftUI

struct HomeSkeletonView: View {

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                heroSkeleton

                VStack(spacing: 28) {
                    ForEach(0..<4, id: \.self) { _ in
                        sectionSkeleton
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Loading")
        }
        .ignoresSafeArea(edges: .top)
    }

    private var heroSkeleton: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .shimmer()
            .aspectRatio(2.6/3, contentMode: .fit)
            .ignoresSafeArea(edges: .top)
    }

    private var sectionSkeleton: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonBox(width: 140, height: 18, cornerRadius: 6)
                .padding(.leading, 60)

            HStack(spacing: 10) {
                Spacer(minLength: 50)

                ForEach(0..<4, id: \.self) { _ in
                    SkeletonBox(width: 100, height: 150)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeSkeletonView()
}
