//
//  DetailDisplay.swift
//  MovieMind
//
//  Created by Semih Söğüt on 12.08.2026.
//

import Foundation

/// The detail responses turned into the strings the UI shows.
/// Kept out of the views: no layout here, just data.

extension MovieDetail {

    var cast: [CastMember] { credits?.cast ?? [] }
    var crew: [CrewMember] { credits?.crew ?? [] }

    var directorNames: [String] {
        crew.filter { $0.job == "Director" }
            .map(\.name)
            .filter { !$0.isEmpty }
    }

    /// Year • runtime • rating • status — whichever the response actually has.
    var metadataItems: [String] {
        [
            releaseDate?.releaseYear,
            runtime > 0 ? "\(runtime / 60)h \(runtime % 60)m" : nil,
            voteAverage > 0 ? String(format: "★ %.1f", voteAverage) : nil,
            status == "Released" || status.isEmpty ? nil : status
        ].compactMap { $0 }
    }
}

extension TVDetail {

    var cast: [CastMember] { credits?.cast ?? [] }

    var creatorNames: [String] {
        createdBy.map(\.name).filter { !$0.isEmpty }
    }

    var episodeStills: [String?] {
        [nextEpisodeToAir?.stillPath, lastEpisodeToAir?.stillPath]
    }

    var metadataItems: [String] {
        [
            firstAirDate?.releaseYear,
            numberOfSeasons > 0 ? "\(numberOfSeasons) Season\(numberOfSeasons == 1 ? "" : "s")" : nil,
            voteAverage > 0 ? String(format: "★ %.1f", voteAverage) : nil,
            status == "Ended" || status == "Canceled" ? status : nil
        ].compactMap { $0 }
    }
}
