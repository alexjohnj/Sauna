//
//  Profile.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

struct Profile: Codable, Hashable, Identifiable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {
        case id = "steamid"
        case name = "personaname"
        case status = "personastate"
        case currentGame = "gameextrainfo"
        case url = "profileurl"
    }

    // MARK: - Public Properties

    var id: SteamID
    var url: URL
    var name: String

    /// If the player's profile is private, this will always be "0" [offline], except if the user has set their status to looking
    /// to trade or looking to play, because a bug makes those status appear even if the profile is private.
    var status: Status

    var currentGame: String?
}

extension Profile {
    static func fixture(
        id: SteamID = "1",
        url: URL = URL(string: "https://steamcommunity.com/id/Gabe/")!,
        name: String = "AJ",
        status: Status = .online,
        currentGame: String? = "Civilization VI"
    ) -> Profile {
        Profile(id: id, url: url, name: name, status: status, currentGame: currentGame)
    }
}
