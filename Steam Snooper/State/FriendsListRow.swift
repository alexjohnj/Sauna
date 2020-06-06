//
//  FriendsListRow.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 06/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
 
enum FriendsListRow: Equatable {

    enum Group: Equatable {
        case online
        case awayFromKeyboard
        case offline

        var localizedDescription: String {
            switch self {
            case .online:
                return "Online"
            case .awayFromKeyboard:
                return "A.F.K."
            case .offline:
                return "Offline"
            }
        }

        var sortRanking: Int {
            switch self {
            case .online:
                return .min
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

extension Profile {
    var groupName: FriendsListRow.Group {
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
