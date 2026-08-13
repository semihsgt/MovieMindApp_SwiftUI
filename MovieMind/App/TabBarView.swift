//
//  TabBarView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 25.06.2026.
//

import SwiftUI
import SwiftData

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
        SavedLibraryKeysProvider {
            tabs
        }
    }

    private var tabs: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            UpcomingView()
                .tabItem { Label("Upcoming", systemImage: "clock") }
            LibraryView()
                .tabItem { Label("Library", systemImage: "rectangle.stack") }
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}

#Preview {
    TabBarView()
        .modelContainer(for: LibraryItem.self, inMemory: true)
}
