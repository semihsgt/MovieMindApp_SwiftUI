//
//  AIService.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import Foundation

struct AIChatTurn: Sendable {
    enum Role: String, Sendable {
        case user
        case model
    }

    let role: Role
    let text: String
}

protocol AIServicing: Sendable {

    /// One-shot prompt with no history — used by the recommendation service.
    func generate<T: Decodable & Sendable>(prompt: String, schema: JSONSchema, as type: T.Type) async throws -> T

    /// A whole conversation. Gemini is stateless, so the caller re-sends the turns
    /// it wants the model to remember.
    func chat<T: Decodable & Sendable>(turns: [AIChatTurn], systemInstruction: String?, schema: JSONSchema, as type: T.Type) async throws -> T
}

enum AIError: Error, LocalizedError {
    case missingKey
    case invalidURL
    case invalidResponse
    case modelUnavailable
    case emptyResponse
    case decodingError(Error)
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .missingKey: return "Gemini API key is not configured."
        case .invalidURL: return "Invalid Gemini URL address."
        case .invalidResponse: return "An invalid response was received from Gemini."
        case .modelUnavailable: return "No supported Gemini model is available for this key."
        case .emptyResponse: return "Gemini returned no usable content."
        case .decodingError(let error): return "Gemini decoding error: \(error.localizedDescription)"
        case .quotaExceeded: return "You've reached today's free AI usage limit. Please try again later."
        }
    }
}
