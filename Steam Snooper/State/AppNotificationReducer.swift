//
//  AppNotificationReducer.swift
//  Steam Snooper
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
        let notifications = statusChangeNotifications(from: currentFriendsList, to: newFriendsList)

        return Effect.fireAndForget {
            env.notifier.postNotifications(notifications)
        }

    case .profilesLoaded(.failure),
         .reloadFriendsList:
        return .none
    }
}

// MARK: - Supporting Methods

private struct StatusChange {
    enum Kind {
        case cameOnline
    }

    let player: Profile
    let kind: Kind
}

private func statusChangeNotifications(from oldFriendsList: [Profile], to newFriendsList: [Profile]) -> [UNNotificationRequest] {
    statusChanges(from: oldFriendsList, in: newFriendsList)
        .map { change in
            let notificationContent = UNMutableNotificationContent()

            switch change.kind {
            case .cameOnline:
                notificationContent.title = "\(change.player.name) is online"
                if let currentGame = change.player.currentGame {
                    notificationContent.subtitle = "Currently playing \(currentGame)"
                }
            }

            let request = UNNotificationRequest(identifier: change.player.id.rawValue, content: notificationContent, trigger: nil)
            return request
    }
}

private func statusChanges(from oldFriendsList: [Profile], in newFriendsList: [Profile]) -> [StatusChange] {
    let previousOnlineFriends = oldFriendsList.filter { $0.status == .online }.sorted(by: { $0.id.rawValue > $1.id.rawValue })
    let currentOnlineFriends = newFriendsList.filter { $0.status == .online }.sorted(by: { $0.id.rawValue > $1.id.rawValue })
    let difference = currentOnlineFriends.difference(from: previousOnlineFriends, by: { $0.id == $1.id })

    return difference.insertions.map { StatusChange(player: $0.element, kind: .cameOnline) }
}
