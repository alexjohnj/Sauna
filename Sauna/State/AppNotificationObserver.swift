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

let appNotificationObserver: Observer<[Profile], AppAction, AppNotificationEnvironment> = Observer { currentFriendsList, action, env in
    switch action {
    case .windowLoaded:
        return Effect.fireAndForget {
            env.notifier.requestAuthorization()
        }
        
    case .profilesLoaded(.success(let newFriendsList)):
        guard !currentFriendsList.isEmpty else { return .none }
        
        let changes = statusChanges(from: currentFriendsList, in: newFriendsList)
        let notificationRequests: [UNNotificationRequest] = changes
            .filter { $0.kind != .wentOffline }
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

private struct StatusChange: Equatable {
    enum Kind: Equatable {
        case cameOnline
        case wentOffline
        case startedPlaying(game: String)
    }
    
    let player: Profile
    let kind: Kind
}

private func statusChanges(from oldFriendsList: [Profile], in newFriendsList: [Profile]) -> [StatusChange] {
    let oldFriendsList = oldFriendsList.sorted { $0.id.rawValue > $1.id.rawValue }
    let newFriendsList = newFriendsList.sorted { $0.id.rawValue > $1.id.rawValue }

    var changes = [StatusChange]()
    var oldFriendsListIterator = oldFriendsList.makeIterator()
    var nextOldFriend = oldFriendsListIterator.next()

    for newFriend in newFriendsList {
        if let oldFriend = nextOldFriend,
            oldFriend.id == newFriend.id {
            changes.append(contentsOf: statusChanges(from: oldFriend, to: newFriend))
            nextOldFriend = oldFriendsListIterator.next()
        } else {
            // A new friend was added to the friends list
            changes.append(contentsOf: statusChangesForNewFriend(newFriend))
        }
    }

    return changes
}

private func statusChanges(from oldFriend: Profile, to newFriend: Profile) -> [StatusChange] {
    assert(oldFriend.id == newFriend.id, "Attempt to get status changes between two different profiles.")
    var changes = [StatusChange]()

    if !oldFriend.status.isTechnicallyOnline,
        newFriend.status.isTechnicallyOnline {
        changes.append(StatusChange(player: newFriend, kind: .cameOnline))
    } else if newFriend.status.isTechnicallyOnline,
        let nowPlayingGame = newFriend.currentGame,
        nowPlayingGame != oldFriend.currentGame {
        changes.append(StatusChange(player: newFriend, kind: .startedPlaying(game: nowPlayingGame)))
    } else if oldFriend.status.isTechnicallyOnline,
        !newFriend.status.isTechnicallyOnline {
        changes.append(StatusChange(player: newFriend, kind: .wentOffline))
    }

    return changes
}

private func statusChangesForNewFriend(_ friend: Profile) -> [StatusChange] {
    var changes = [StatusChange]()
    if friend.status.isTechnicallyOnline {
        changes.append(StatusChange(player: friend, kind: .cameOnline))
    }
    return []
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

    case .startedPlaying(let gameName):
        content.body = "\(statusChange.player.name) is now playing \(gameName)"
    }
    
    return content
}
