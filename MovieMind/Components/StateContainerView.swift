//
//  StateContainerView.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import SwiftUI

/// The shared failure screen: what went wrong plus a button that re-runs the load.
struct ErrorRetryView: View {
    
    let error: Error
    let retryAction: () async -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: "wifi.exclamationmark")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                Task { await retryAction() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

/// Renders a `ViewState` so screens never branch on it themselves: the caller
/// supplies a skeleton and the loaded content, and gets the idle, loading and
/// failure cases handled the same way everywhere.
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

        case .failed(let error):
            ErrorRetryView(error: error, retryAction: retryAction)
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
    StateContainerView(state: ViewState<[String]>.failed(NetworkError.invalidResponse), retryAction: {}) { _ in
        Text("Content")
    }
}

#Preview("Loaded") {
    StateContainerView(state: .loaded(["Dune", "The Last of Us"]), retryAction: {}) { items in
        List(items, id: \.self) { Text($0) }
    }
}
