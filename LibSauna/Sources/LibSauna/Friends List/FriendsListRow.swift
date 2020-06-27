//
//  FriendsListRow.swift
//  Sauna
//
//  Created by Alex Jackson on 06/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

public enum FriendsListRow: Equatable {

    public enum Group: Equatable {
        case inGame
        case online
        case awayFromKeyboard
        case offline

        public var localizedDescription: String {
            switch self {
            case .inGame:
                return "In Game"
            case .online:
                return "Online"
            case .awayFromKeyboard:
                return "A.F.K."
            case .offline:
                return "Offline"
            }
        }

        public var sortRanking: Int {
            switch self {
            case .inGame:
                return .min
            case .online:
                return Group.inGame.sortRanking + 1
            case .offline:
                return .max
            case .awayFromKeyboard:
                return Group.offline.sortRanking - 1
            }
        }
    }

    case friend(Profile)
    case groupHeader(Group)
}

public extension Profile {
    var groupName: FriendsListRow.Group {
        guard currentGame == nil else {
            return .inGame
        }

        switch status {
        case .online,
             .lookingToPlay,
             .lookingToTrade:
            return .online

        case .busy,
             .snooze,
             .away:
            return .awayFromKeyboard

        case .offline:
            return .offline
        }
    }
}
