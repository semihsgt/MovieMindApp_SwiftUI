//
//  Secrets.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation

enum Secrets {

    static let apiKey = value(for: "TMDB_API_KEY", placeholder: "YOUR_API_KEY_HERE")
    static let geminiApiKey = value(for: "GEMINI_API_KEY", placeholder: "YOUR_GEMINI_API_KEY_HERE")

    private static func value(for key: String, placeholder: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty,
              value != placeholder else {
            return nil
        }
        return value
    }
}
