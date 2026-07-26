//
//  AIChatService.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import Foundation

struct AIChatResult: Sendable {
    let reply: String
    let items: [MediaItem]
}

private struct AIChatPayload: Decodable, Sendable {
    let reply: String
    let titles: [AIRecommendation]?
}

actor AIChatService {

    static let shared = AIChatService()

    private let ai: AIServicing
    private let network: NetworkServicing

    init(ai: AIServicing = GeminiService.shared,
         network: NetworkServicing = NetworkManager.shared) {
        self.ai = ai
        self.network = network
    }

    func send(history: [AIChatTurn]) async throws -> AIChatResult {
        let schema = JSONSchema.object(
            properties: [
                ("reply", .string),
                ("titles", .array(items: .object(
                    properties: [
                        ("title", .string),
                        ("year", .string),
                        ("mediaType", .string)
                    ],
                    required: ["title", "mediaType"]
                )))
            ],
            required: ["reply"]
        )

        let payload = try await ai.chat(
            turns: history,
            systemInstruction: Self.systemInstruction,
            schema: schema,
            as: AIChatPayload.self
        )

        let items = await AIMediaResolver.resolve(payload.titles ?? [], using: network)
        return AIChatResult(reply: payload.reply, items: items)
    }

    private static let systemInstruction = """
    You are MovieMind's built-in movie and TV recommendation assistant. Interpret the user's \
    request, which may mention mood, genre, era, actors, or a title they liked, and suggest \
    relevant, well-known movies or TV shows. Reply in the same language the user writes in, \
    using a short and warm conversational tone of one to three sentences. Put your spoken \
    answer in "reply" and the concrete suggestions in "titles". For each title give the exact \
    commonly-used English title, its 4-digit release year, and a mediaType of either "movie" \
    or "tv". Prefer findable, well-known titles. If the user is only chatting, still offer a \
    few relevant suggestions when it makes sense.
    """
}
