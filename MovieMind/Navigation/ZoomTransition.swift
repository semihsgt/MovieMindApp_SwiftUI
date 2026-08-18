//
//  ZoomTransition.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import SwiftUI

private struct ZoomNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var zoomNamespace: Namespace.ID? {
        get { self[ZoomNamespaceKey.self] }
        set { self[ZoomNamespaceKey.self] = newValue }
    }
}

private struct ZoomSourceModifier<ID: Hashable>: ViewModifier {
    let id: ID
    @Environment(\.zoomNamespace) private var namespace

    func body(content: Content) -> some View {
        if let namespace {
            content.matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

extension View {

    /// Publishes the screen's namespace so nested views can mark themselves as a
    /// zoom source without it being threaded through every initializer.
    func zoomNamespace(_ namespace: Namespace.ID) -> some View {
        environment(\.zoomNamespace, namespace)
    }

    /// Marks this view as the thing the pushed screen zooms out of. Does nothing
    /// when no namespace is in the environment.
    func zoomSource<ID: Hashable>(id: ID) -> some View {
        modifier(ZoomSourceModifier(id: id))
    }

    func zoomDestination<ID: Hashable>(id: ID, in namespace: Namespace.ID) -> some View {
        navigationTransition(.zoom(sourceID: id, in: namespace))
    }
}
