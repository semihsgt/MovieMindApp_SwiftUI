//
//  CreditsModels.swift
//  MovieMind
//
//  Created by Semih Söğüt on 28.06.2026.
//

import Foundation

struct Credits: Decodable {
    let cast: [CastMember]?
    let crew: [CrewMember]?
}

struct CastMember: Decodable {
    let id: Int?
    let name: String?
    let character: String?
    let profilePath: String?
    let order: Int?
    let creditId: String?

    var uniqueId: String { creditId ?? "\(id ?? 0)" }
}

struct CrewMember: Decodable {
    let id: Int?
    let name: String?
    let job: String?
    let department: String?
}

struct CombinedCredits: Decodable {
    let id: Int?
    let cast: [MediaItem]?
}
