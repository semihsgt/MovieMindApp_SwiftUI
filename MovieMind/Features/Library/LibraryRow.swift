//
//  LibraryRow.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct LibraryRow: View {
    let icon: String
    let iconColor: Color
    let route: LibraryRoute

    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(iconColor)

                Text(route.title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}
