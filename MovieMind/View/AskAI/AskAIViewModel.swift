//
//  AskAIViewModel.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import SwiftUI

@MainActor
@Observable
final class AskAIViewModel {

    struct Message: Identifiable {
        enum Role {
            case user
            case assistant
        }

        let id = UUID()
        let role: Role
        let text: String
        var items: [MediaItem] = []
    }

    private(set) var messages: [Message] = []
    var input: String = ""
    private(set) var isResponding = false
    private let chatService: AIChatService

    init(chatService: AIChatService = .shared) {
        self.chatService = chatService
    }

    var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isResponding
    }

    func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isResponding else { return }

        messages.append(Message(role: .user, text: text))
        input = ""
        isResponding = true
        defer { isResponding = false }

        let history = messages.map {
            AIChatTurn(role: $0.role == .user ? .user : .model, text: $0.text)
        }

        do {
            let result = try await chatService.send(history: history)
            messages.append(Message(role: .assistant, text: result.reply, items: result.items))
        } catch {
            let message: String
            switch error as? AIError {
            case .missingKey:
                message = "AI is not configured. Add a Gemini API key to enable this feature."
            case .quotaExceeded:
                message = "You've reached today's free AI usage limit. Please try again later."
            default:
                message = "I couldn't respond just now. Please try again."
            }
            messages.append(Message(role: .assistant, text: message))
        }
    }
}
