//
//  FriendsListResponse.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

struct FriendsListResponse: Decodable, Equatable {

    // MARK: - Nested Types

    private struct SteamIDWrapper: Decodable, Equatable {
        let steamid: SteamID
    }

    private struct FriendsList: Decodable, Equatable {
        let friends: [SteamIDWrapper]
    }

    private enum CodingKeys: String, CodingKey {
        case _friendsList = "friendslist"
    }

    // MARK: - Public Properties

    var friends: [SteamID] {
        _friendsList.friends.map(\.steamid)
    }

    // MARK: - Private Properties

    private let _friendsList: FriendsList
}
