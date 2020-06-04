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
    }
}
