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
    func zoomNamespace(_ namespace: Namespace.ID) -> some View {
        environment(\.zoomNamespace, namespace)
    }

    func zoomSource<ID: Hashable>(id: ID) -> some View {
        modifier(ZoomSourceModifier(id: id))
    }

    func zoomDestination<ID: Hashable>(id: ID, in namespace: Namespace.ID) -> some View {
        navigationTransition(.zoom(sourceID: id, in: namespace))
    }
}
