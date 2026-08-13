//
//  JSONSchema.swift
//  MovieMind
//
//  Created by Semih Söğüt on 21.07.2026.
//

import Foundation

/// The response shape sent to Gemini as `responseSchema`, which is what makes the
/// model reply with parseable JSON instead of prose.
indirect enum JSONSchema: Sendable {
    case string
    case integer
    case number
    case boolean
    case array(items: JSONSchema)
    case object(properties: [(String, JSONSchema)], required: [String])
}

/// Gemini's dialect, not plain JSON Schema: uppercase type names, and an explicit
/// `propertyOrdering` because a Swift dictionary would otherwise scramble the keys.
extension JSONSchema: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type, items, properties, required, propertyOrdering
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string:
            try container.encode("STRING", forKey: .type)
        case .integer:
            try container.encode("INTEGER", forKey: .type)
        case .number:
            try container.encode("NUMBER", forKey: .type)
        case .boolean:
            try container.encode("BOOLEAN", forKey: .type)
        case .array(let items):
            try container.encode("ARRAY", forKey: .type)
            try container.encode(items, forKey: .items)
        case .object(let properties, let required):
            try container.encode("OBJECT", forKey: .type)
            var dictionary: [String: JSONSchema] = [:]
            for (key, value) in properties { dictionary[key] = value }
            try container.encode(dictionary, forKey: .properties)
            try container.encode(required, forKey: .required)
            try container.encode(properties.map(\.0), forKey: .propertyOrdering)
        }
    }
}
