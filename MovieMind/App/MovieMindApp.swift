//
//  MovieMindApp.swift
//  MovieMind
//
//  Created by Semih Söğüt on 24.06.2026.
//

import SwiftUI
import SwiftData
import Nuke

@main
struct MovieMindApp: App {
    
    init() {
        URLCache.shared.memoryCapacity = 10 * 1024 * 1024   // 10 MB
        URLCache.shared.diskCapacity = 20 * 1024 * 1024     // 20 MB
        
        ImagePipeline.shared = Self.makeImagePipeline()
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .tint(.red)
        }
        .modelContainer(for: LibraryItem.self)
    }
    
    private static func makeImagePipeline() -> ImagePipeline {
        
        var configuration = ImagePipeline.Configuration()
        
        if let dataCache = try? DataCache(name: "net.btpro.moviemind.imagecache") {
            dataCache.sizeLimit = 250 * 1024 * 1024 // 250 MB, hard cap
            configuration.dataCache = dataCache
        }
        
        let imageCache = Nuke.ImageCache()
        imageCache.costLimit = 80 * 1024 * 1024 // 80 MB of decoded bitmaps
        configuration.imageCache = imageCache
        
        configuration.dataCachePolicy = .automatic
        
        return ImagePipeline(configuration: configuration)
    }
}
