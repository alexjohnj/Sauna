//
//  Profile.Status.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

extension Profile {
    enum Status: Int, Codable {
        case offline = 0
        case online
        case busy
        case away
        case snooze
        case lookingToTrade
        case lookingToPlay

        /// Integer describing the logical ranking of the receiver.
        var sortRanking: Int16 {
            switch self {
            case .offline:
                return .max // Offline should always sort last
            case .online:
                return .min // Online should always sort first
            case .busy:
                return Status.away.sortRanking - 1
            case .away:
                return Status.snooze.sortRanking - 1
            case .snooze:
                return Status.offline.sortRanking - 1
            case .lookingToTrade:
                return Status.lookingToPlay.sortRanking + 1
            case .lookingToPlay:
                return Status.online.sortRanking + 1
            }
        }
    }
}
