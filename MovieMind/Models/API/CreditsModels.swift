//
//  CreditsModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

struct Credits: Decodable, Sendable {
    @Fallback var cast: [CastMember] = []
    @Fallback var crew: [CrewMember] = []
}

struct CastMember: Decodable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    @Fallback var character: String = ""
    let profilePath: String?
    let creditId: String?

    /// The same actor can appear twice in one cast list, so the credit is the identity.
    var uniqueId: String { creditId ?? "\(id ?? 0)" }
}

struct CrewMember: Decodable, Sendable {
    let id: Int?
    @Fallback var name: String = ""
    @Fallback var job: String = ""
}

struct CombinedCredits: Decodable, Sendable {
    let id: Int?
    @Fallback var cast: [MediaItem] = []
}
