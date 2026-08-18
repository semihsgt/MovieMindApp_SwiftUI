//
//  ViewState.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation

/// The four states every screen can be in. Modelling them as one enum makes
/// conflicting combinations — loading *and* failed, loaded *and* empty — impossible
/// to represent, and `StateContainerView` renders each case for free.
enum ViewState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)

    /// The loaded value, or nil in any other state.
    var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }
}
