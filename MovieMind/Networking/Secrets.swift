//
//  Secrets.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation

enum Secrets {
    
    static let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
              !key.isEmpty,
              key != "YOUR_API_KEY_HERE" else {
            fatalError("TMDB_API_KEY is missing. Copy SecretsExample.xcconfig as Secrets.xcconfig and add your key.")
        }
        return key
    }()
}
