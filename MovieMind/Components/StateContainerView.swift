//
//  StateContainerView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

struct ErrorRetryView: View {
    let message: String
    let retryAction: () async -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task { await retryAction() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct StateContainerView<Value, Loading: View, Content: View>: View {
    let state: ViewState<Value>
    let retryAction: () async -> Void
    @ViewBuilder let loading: () -> Loading
    @ViewBuilder let content: (Value) -> Content

    var body: some View {
        switch state {
        case .idle, .loading:
            loading()
                .transition(.opacity)

        case .failed(let message):
            ErrorRetryView(message: message, retryAction: retryAction)
                .containerRelativeFrame(.vertical)

        case .loaded(let value):
            content(value)
                .transition(.opacity)
        }
    }
}

extension StateContainerView where Loading == DefaultLoadingView {
    init(state: ViewState<Value>,
         retryAction: @escaping () async -> Void,
         @ViewBuilder content: @escaping (Value) -> Content) {
        self.init(state: state,
                  retryAction: retryAction,
                  loading: { DefaultLoadingView() },
                  content: content)
    }
}

struct DefaultLoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Loading") {
    StateContainerView(state: ViewState<[String]>.loading, retryAction: {}) { _ in
        Text("Content")
    }
}

#Preview("Failed") {
    StateContainerView(state: ViewState<[String]>.failed("The Internet connection appears to be offline."), retryAction: {}) { _ in
        Text("Content")
    }
}

#Preview("Loaded") {
    StateContainerView(state: .loaded(["Dune", "The Last of Us"]), retryAction: {}) { items in
        List(items, id: \.self) { Text($0) }
    }
}

#Preview("Custom Skeleton") {
    StateContainerView(state: ViewState<[String]>.loading) {
    } loading: {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.08))
            .frame(width: 200, height: 300)
            .shimmer()
    } content: { _ in
        Text("Content")
    }
}
