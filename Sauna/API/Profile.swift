//
//  Profile.swift
//  Sauna
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
        case realName = "realname"
        case status = "personastate"
        case currentGame = "gameextrainfo"
        case url = "profileurl"
        case lastOnlineTime = "lastlogoff"
    }

    // MARK: - Type Properties

    public static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    // MARK: - Public Properties

    var id: SteamID
    var url: URL
    var name: String
    var realName: String?

    /// If the player's profile is private, this will always be "0" [offline], except if the user has set their status to looking
    /// to trade or looking to play, because a bug makes those status appear even if the profile is private.
    var status: Status

    var lastOnlineTime: Date

    var currentGame: String?
}

#if DEBUG
extension Profile {
    static func fixture(
        id: SteamID = .valid,
        url: URL = URL(string: "https://steamcommunity.com/id/Gabe/")!,
        name: String = "AJ",
        realName: String? = nil,
        status: Status = .online,
        lastOnlineTime: Date = Date(timeIntervalSinceNow: -86400),
        currentGame: String? = nil
    ) -> Profile {
        Profile(
            id: id,
            url: url,
            name: name,
            realName: realName,
            status: status,
            lastOnlineTime: lastOnlineTime,
            currentGame: currentGame
        )
    }
}
#endif
