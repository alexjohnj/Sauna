//
//  AppNotificationReducer.swift
//  Sauna
//
//  Created by Alex Jackson on 14/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import UserNotifications

import ComposableArchitecture

struct AppNotificationEnvironment {
    var notifier: Notifier
}

let appNotificationReducer: Observer<[Profile], AppAction, AppNotificationEnvironment> = Observer { currentFriendsList, action, env in
    switch action {
    case .windowLoaded:
        return Effect.fireAndForget {
            env.notifier.requestAuthorization()
        }
        
    case .profilesLoaded(.success(let newFriendsList)):
        guard !currentFriendsList.isEmpty else { return .none }
        
        let changes = statusChanges(from: currentFriendsList, in: newFriendsList)
        let notificationRequests: [UNNotificationRequest] = changes
            .filter { $0.kind == .cameOnline }
            .map { change in
                let content = notificationContent(for: change)
                return UNNotificationRequest(identifier: change.player.id.rawValue, content: content, trigger: nil)
        }
        let noteIdentifiersToRemove = changes
            .filter { $0.kind == .wentOffline }
            .map(\.player.id.rawValue)
        
        return Effect.fireAndForget {
            env.notifier.postNotifications(notificationRequests)
            env.notifier.removeDeliveredNotifications(noteIdentifiersToRemove)
        }

    default:
        return .none
    }
}

// MARK: - Supporting Methods

private struct StatusChange {
    enum Kind {
        case cameOnline
        case wentOffline
    }
    
    let player: Profile
    let kind: Kind
}

private func statusChanges(from oldFriendsList: [Profile], in newFriendsList: [Profile]) -> [StatusChange] {
    func findOnlineFriends(in list: [Profile]) -> [Profile] {
        list.filter(\.status.isTechnicallyOnline).sorted { $0.id.rawValue > $1.id.rawValue }
    }
    
    let previousOnlineFriends = findOnlineFriends(in: oldFriendsList)
    let currentOnlineFriends = findOnlineFriends(in: newFriendsList)
    let difference = currentOnlineFriends.difference(from: previousOnlineFriends, by: { $0.id == $1.id })
    
    return difference.map { change in
        switch change {
        case .insert(_, let player, _):
            return StatusChange(player: player, kind: .cameOnline)
        case .remove(_, let profile, _):
            return StatusChange(player: profile, kind: .wentOffline)
        }
    }
}

private func notificationContent(for statusChange: StatusChange) -> UNNotificationContent {
    let content = UNMutableNotificationContent()
    switch statusChange.kind {
    case .cameOnline:
        content.title = "\(statusChange.player.name) is online"
        if let currentGame = statusChange.player.currentGame {
            content.subtitle = "Currently playing \(currentGame)"
        }
        
    case .wentOffline:
        content.title = "\(statusChange.player.name) is offline"
    }
    
    return content
}
