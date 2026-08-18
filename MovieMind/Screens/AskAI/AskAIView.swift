//
//  AskAIView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import SwiftUI

struct AskAIView: View {
    
    @State private var viewModel = AskAIViewModel()
    var initialQuery: String? = nil
    private static let typingAnchor = "ai-typing-indicator"
    private let examples = [
        "A light comedy for tonight",
        "Mind-bending sci-fi movies",
        "Shows like The Office"
    ]

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.messages.isEmpty && !viewModel.isResponding {
                ScrollView {
                    introView
                        .containerRelativeFrame(.vertical)
                }
                .scrollBounceBehavior(.always)
                .scrollDismissesKeyboard(.interactively)
            } else {
                messagesScroll
            }

            inputBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Movie Mind AI")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let query = initialQuery?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !query.isEmpty, viewModel.messages.isEmpty {
                viewModel.input = query
                await viewModel.send()
            }
        }
    }

    private var messagesScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isResponding {
                        TypingIndicator()
                            .id(Self.typingAnchor)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { scrollToBottom(proxy) }
            .onChange(of: viewModel.isResponding) { scrollToBottom(proxy) }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            if viewModel.isResponding {
                proxy.scrollTo(Self.typingAnchor, anchor: .bottom)
            } else if let last = viewModel.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    private var introView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.red)
                .accessibilityHidden(true)

            Text("Ask Movie Mind AI")
                .font(.title2.bold())
                .fontDesign(.rounded)

            Text("Describe a mood, a genre, or something you liked, and I'll suggest what to watch.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 300)

            VStack(spacing: 8) {
                ForEach(examples, id: \.self) { example in
                    Button {
                        viewModel.input = example
                        Task { await viewModel.send() }
                    } label: {
                        Text(example)
                            .font(.subheadline)
                            .frame(width: 250)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground), in: .capsule)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask for a recommendation…", text: $viewModel.input)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground), in: .capsule)
                .submitLabel(.send)
                .onSubmit(send)

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(viewModel.canSend ? .red : .gray)
            }
            .disabled(!viewModel.canSend)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func send() {
        guard viewModel.canSend else { return }
        Task { await viewModel.send() }
    }
}

#Preview {
    NavigationStack {
        AskAIView()
    }
}
