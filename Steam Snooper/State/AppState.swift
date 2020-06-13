//
//  AppState.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import ComposableArchitecture
import CasePaths

let kFriendsListRefreshInterval: TimeInterval = 2 * 60

struct AppState: Equatable {
    var userID: SteamID
    var friendsList = Loadable<[FriendsListRow], String>()
    var lastRefreshDate: Date?
}

enum AppAction: Equatable {
    case windowLoaded
    case reloadFriendsList
    case profilesLoaded(Result<[Profile], SteamClient.Failure>)
}

struct AppEnvironment {
    var client: SteamClient
    var notifier: Notifier
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var date: () -> Date
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer { state, action, env in
    struct RefreshTimerID: Hashable { }
    
    switch action {
    case .windowLoaded where state.friendsList.isLoaded == false:
        return Effect.merge(
            Effect(value: .reloadFriendsList),
            Effect.fireAndForget {
                env.notifier.requestAuthorization()
            }
        )
    case .windowLoaded:
        return Effect.fireAndForget {
            env.notifier.requestAuthorization()
        }
        
    case .reloadFriendsList where state.friendsList.isLoading == false:
        state.friendsList.startLoading()
        
        return Effect.merge(
            Effect.cancel(id: RefreshTimerID()),
            env.client.getFriendsList(state.userID)
                .flatMap(env.client.getProfiles)
                .catchToEffect()
                .map(AppAction.profilesLoaded)
                .receive(on: env.mainScheduler)
                .eraseToEffect()
        )
        
    case .reloadFriendsList:
        return .none
        
    case .profilesLoaded(.success(let newFriendsList)):
        let oldFriendsList = state.friendsList.data?.compactMap(/FriendsListRow.friend) ?? []

        state.friendsList.complete(groupAndSortProfiles(newFriendsList))
        state.lastRefreshDate = env.date()
        
        let notifications = statusChangeNotifications(from: oldFriendsList, to: newFriendsList)
        
        return Effect.merge(
            Effect.fireAndForget {
                env.notifier.postNotifications(notifications)
            },
            Effect.timer(id: RefreshTimerID(), every: .seconds(kFriendsListRefreshInterval), tolerance: 0, on: env.mainScheduler)
                .map { _ in AppAction.reloadFriendsList }
                .eraseToEffect()
        )
        
    case .profilesLoaded(.failure(let error)):
        state.friendsList.fail(with: error.failureReason ?? "Failed to load the friends list.")
        
        return Effect.timer(id: RefreshTimerID(), every: .seconds(kFriendsListRefreshInterval), tolerance: 0, on: env.mainScheduler)
            .map { _ in AppAction.reloadFriendsList }
            .eraseToEffect()
    }
}

// MARK: - Helper Functions

private func groupAndSortProfiles(_ profiles: [Profile]) -> [FriendsListRow] {
    return Dictionary<FriendsListRow.Group, [Profile]>(grouping: profiles, by: \.groupName)
        .mapValues(sortProfiles) // Sort contents of each group
        .sorted { $0.key.sortRanking < $1.key.sortRanking } // Sort groups
        .reduce(into: []) { accum, group in // Flatten groups and profiles into single array
            accum.append(.groupHeader(group.key))
            accum.append(contentsOf: group.value.map(FriendsListRow.friend))
    }
}

private func sortProfiles(_ profiles: [Profile]) -> [Profile] {
    return profiles.sorted { profile, otherProfile in
        if profile.status.sortRanking == otherProfile.status.sortRanking {
            // Sort people in a game to the front
            switch (profile.currentGame, otherProfile.currentGame) {
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.some(let game), .some(let otherGame)):
                return game < otherGame // This will group people playing the same game together
            case (.none, .none):
                return profile.name < otherProfile.name
            }
        } else {
            return profile.status.sortRanking < otherProfile.status.sortRanking
        }
    }
}

// MARK: - Notification Support

import UserNotifications

private func statusChangeNotifications(from oldFriendsList: [Profile], to newFriendsList: [Profile]) -> [UNNotificationRequest] {
    guard !oldFriendsList.isEmpty else {
        return []
    }

    return statusChanges(from: oldFriendsList, in: newFriendsList)
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

private struct StatusChange {
    enum Kind {
        case cameOnline
    }
    
    let player: Profile
    let kind: Kind
}

private func statusChanges(from oldFriendsList: [Profile], in newFriendsList: [Profile]) -> [StatusChange] {
    let previousOnlineFriends = oldFriendsList.filter { $0.status == .online }
    let currentOnlineFriends = newFriendsList.filter { $0.status == .online }
    let difference = currentOnlineFriends.difference(from: previousOnlineFriends, by: { $0.id == $1.id })
    
    return difference.insertions.map { StatusChange(player: $0.element, kind: .cameOnline) }
}

private extension CollectionDifference.Change {
    var element: ChangeElement {
        switch self {
        case .insert(_, let element, _),
             .remove(_, let element, _):
            return element
        }
    }
}
