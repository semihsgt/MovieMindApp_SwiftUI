//
//  TabBarView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI

struct TabBarView: View {

    @State private var isSplashFinished = false
    
    var body: some View {
        ZStack {
            TabBarsView
            
            if !isSplashFinished {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            withAnimation(.easeOut(duration: 0.5)) { isSplashFinished = true }
        }
    }
    
    private var TabBarsView: some View {
        TabView {
            HomePageView()
                .tabItem { Label("Home", systemImage: "house") }
            UpcomingPageView()
                .tabItem { Label("Upcoming", systemImage: "clock") }
            LibraryPageView()
                .tabItem { Label("Library", systemImage: "rectangle.stack") }
            SearchPageView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}

#Preview {
    TabBarView()
}
