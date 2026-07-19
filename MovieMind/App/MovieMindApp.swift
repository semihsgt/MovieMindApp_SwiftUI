//
//  MovieMindApp.swift
//  MovieMind
//
//  Created by Semih Söğüt on 24.06.2026.
//

import SwiftUI
import SwiftData

@main
struct MovieMindApp: App {
    
    init() {
        URLCache.shared.memoryCapacity = 50 * 1024 * 1024   // 50 MB
        URLCache.shared.diskCapacity = 200 * 1024 * 1024    // 200 MB
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .tint(.red)
        }
        .modelContainer(for: WatchlistItem.self)
    }
}
