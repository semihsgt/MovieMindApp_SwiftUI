//
//  GeminiService.swift
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
    func generate<T: Decodable & Sendable>(prompt: String, schema: JSONSchema, as type: T.Type) async throws -> T
    func chat<T: Decodable & Sendable>(turns: [AIChatTurn], systemInstruction: String?, schema: JSONSchema, as type: T.Type) async throws -> T
}

enum AIError: Error, LocalizedError {
    case missingKey
    case invalidURL
    case invalidResponse
    case modelUnavailable
    case emptyResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .missingKey: return "Gemini API key is not configured."
        case .invalidURL: return "Invalid Gemini URL address."
        case .invalidResponse: return "An invalid response was received from Gemini."
        case .modelUnavailable: return "No supported Gemini model is available for this key."
        case .emptyResponse: return "Gemini returned no usable content."
        case .decodingError(let error): return "Gemini decoding error: \(error.localizedDescription)"
        }
    }
}

indirect enum JSONSchema: Sendable {
    case string
    case integer
    case number
    case boolean
    case array(items: JSONSchema)
    case object(properties: [(String, JSONSchema)], required: [String])
}

extension JSONSchema: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type, items, properties, required, propertyOrdering
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string:
            try container.encode("STRING", forKey: .type)
        case .integer:
            try container.encode("INTEGER", forKey: .type)
        case .number:
            try container.encode("NUMBER", forKey: .type)
        case .boolean:
            try container.encode("BOOLEAN", forKey: .type)
        case .array(let items):
            try container.encode("ARRAY", forKey: .type)
            try container.encode(items, forKey: .items)
        case .object(let properties, let required):
            try container.encode("OBJECT", forKey: .type)
            var dictionary: [String: JSONSchema] = [:]
            for (key, value) in properties { dictionary[key] = value }
            try container.encode(dictionary, forKey: .properties)
            try container.encode(required, forKey: .required)
            try container.encode(properties.map(\.0), forKey: .propertyOrdering)
        }
    }
}

actor GeminiService: AIServicing {

    static let shared = GeminiService()
    private init() {}

    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"

    private let modelCandidates = [
        "gemini-flash-lite-latest",
        "gemini-flash-latest",
        "gemini-2.5-flash"
    ]
    private var resolvedModel: String?

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func generate<T: Decodable & Sendable>(prompt: String, schema: JSONSchema, as type: T.Type) async throws -> T {
        let contents = [GeminiRequest.Content(role: "user", parts: [.init(text: prompt)])]
        return try await run(contents: contents, systemInstruction: nil, schema: schema, as: T.self)
    }

    func chat<T: Decodable & Sendable>(turns: [AIChatTurn], systemInstruction: String?, schema: JSONSchema, as type: T.Type) async throws -> T {
        let contents = turns.map {
            GeminiRequest.Content(role: $0.role.rawValue, parts: [.init(text: $0.text)])
        }
        return try await run(contents: contents, systemInstruction: systemInstruction, schema: schema, as: T.self)
    }

    private func run<T: Decodable & Sendable>(contents: [GeminiRequest.Content],
                                              systemInstruction: String?,
                                              schema: JSONSchema,
                                              as type: T.Type) async throws -> T {
        guard let apiKey = Secrets.geminiApiKey else { throw AIError.missingKey }

        let candidates = resolvedModel.map { [$0] } ?? modelCandidates
        var lastError: Error = AIError.modelUnavailable

        for model in candidates {
            do {
                let result = try await send(contents: contents, systemInstruction: systemInstruction,
                                            schema: schema, model: model, apiKey: apiKey, as: T.self)
                resolvedModel = model
                return result
            } catch AIError.modelUnavailable {
                lastError = AIError.modelUnavailable
                continue
            }
        }

        throw lastError
    }

    private func send<T: Decodable & Sendable>(contents: [GeminiRequest.Content],
                                               systemInstruction: String?,
                                               schema: JSONSchema,
                                               model: String, apiKey: String,
                                               as type: T.Type) async throws -> T {
        guard var components = URLComponents(string: "\(baseURL)/\(model):generateContent") else {
            throw AIError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else { throw AIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20

        let body = GeminiRequest(
            contents: contents,
            systemInstruction: systemInstruction.map { .init(parts: [.init(text: $0)]) },
            generationConfig: .init(responseMimeType: "application/json", responseSchema: schema)
        )
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 404 { throw AIError.modelUnavailable }
            throw AIError.invalidResponse
        }

        let envelope = try decoder.decode(GeminiResponse.self, from: data)
        guard let text = envelope.candidates?.first?.content?.parts?.first?.text,
              let jsonData = text.data(using: .utf8) else {
            throw AIError.emptyResponse
        }

        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            throw AIError.decodingError(error)
        }
    }
}

private struct GeminiRequest: Encodable {
    let contents: [Content]
    let systemInstruction: SystemInstruction?
    let generationConfig: GenerationConfig

    struct Content: Encodable {
        let role: String
        let parts: [Part]
    }

    struct Part: Encodable {
        let text: String
    }

    struct SystemInstruction: Encodable {
        let parts: [Part]
    }

    struct GenerationConfig: Encodable {
        let responseMimeType: String
        let responseSchema: JSONSchema
    }
}

private struct GeminiResponse: Decodable {
    let candidates: [Candidate]?

    struct Candidate: Decodable {
        let content: Content?
    }

    struct Content: Decodable {
        let parts: [Part]?
    }

    struct Part: Decodable {
        let text: String?
    }
}
