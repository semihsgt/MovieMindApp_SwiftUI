//
//  Fallback.swift
//  MovieMind
//
//  Created by Semih Söğüt on 12.08.2026.
//

import Foundation

/// A type whose "nothing was sent" value is its empty form: "", 0, false, [], [:].
protocol EmptyRepresentable {
    init()
}

extension String: EmptyRepresentable {}
extension Int: EmptyRepresentable {}
extension Double: EmptyRepresentable {}
extension Bool: EmptyRepresentable {}
extension Array: EmptyRepresentable {}
extension Dictionary: EmptyRepresentable {}

/// Keeps a decoded property non-optional. When the API omits the key, sends
/// null, or sends the wrong type, the property falls back to its empty value
/// instead of failing the whole response.
///
/// Every wrapped property needs an inline initial value (`= ""`, `= []`, …).
/// Without one Swift routes the memberwise initializer through `init()` and its
/// parameter becomes `Fallback<…>` instead of the value itself.
@propertyWrapper
struct Fallback<Value: Decodable & Sendable & EmptyRepresentable>: Decodable, Sendable {

    var wrappedValue: Value

    init(wrappedValue: Value = Value()) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        wrappedValue = (try? Value(from: decoder)) ?? Value()
    }
}

/// Covers the third failure: a key that isn't in the payload at all. Without
/// this overload the synthesized decoder would throw `keyNotFound` before
/// `Fallback.init(from:)` ever runs.
extension KeyedDecodingContainer {

    func decode<Value>(_ type: Fallback<Value>.Type,
                       forKey key: Key) throws -> Fallback<Value> {
        try decodeIfPresent(type, forKey: key) ?? Fallback()
    }
}
