//
//  AINoticeBanner.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import SwiftUI

struct AINoticeBanner: View {
    
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
                .font(.footnote)
                .padding(.top, 2)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding()
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}
