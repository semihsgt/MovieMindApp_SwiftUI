//
//  ViewState.swift
//  MovieMind
//
//  Created by Semih Söğüt on 6.07.2026.
//

import Foundation

enum ViewState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }
}
