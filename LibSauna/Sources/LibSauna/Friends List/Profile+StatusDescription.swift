//
//  File.swift
//  
//
//  Created by Alex Jackson on 27/06/2020.
//

import Foundation

extension Profile {
    public var statusDescription: String? {
        if let currentGame = currentGame {
            return "Playing \(currentGame)"
        }

        switch status {
        case .away:
            return "Away"
        case .busy:
            return "Busy"
        case .snooze:
            return "Snooze"
        case .lookingToTrade:
            return "Looking to Trade"
        case .lookingToPlay:
            return "Looking to Play"
        default:
            return nil
        }
    }
}
