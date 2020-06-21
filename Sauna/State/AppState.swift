//
//  AppState.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine
import ComposableArchitecture
import CasePaths

let kFriendsListRefreshInterval: TimeInterval = 2 * 60

struct AppState: Equatable {
    var friendsList = Loadable<[FriendsListRow], String>()
    var lastRefreshDate: Date?
    var setupWindowState: SetupWindowState?
    
    var loadedProfiles: [Profile] {
        friendsList.data?.compactMap(/FriendsListRow.friend) ?? []
    }
}

enum AppAction: Equatable {
    case windowLoaded
    case reloadFriendsList
    case profilesLoaded(Result<[Profile], SteamClient.Failure>)

    case startSetupWindow
    case setupWindowAction(SetupWindowAction)
    case signOut
}

struct AppEnvironment {
    var client: SteamClient
    var notifier: Notifier
    var credentialStore: CredentialStore
    var preferences: Preferences

    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var date: () -> Date
}

let appStateReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer { state, action, env in
    switch action {
    case .windowLoaded:
        return Effect.running(env.credentialStore.getCredentials)
            .map { $0 == nil ? AppAction.startSetupWindow : AppAction.reloadFriendsList }
            .eraseToEffect()

    case .startSetupWindow:
        state.setupWindowState = SetupWindowState()
        return .none

    case .reloadFriendsList where state.friendsList.isLoading == false:
        state.friendsList.startLoading()

        return Effect.running(env.credentialStore.getCredentials)
            .compactMap { $0 } // This is bad, need to make this produce a failure instead.
            .setFailureType(to: SteamClient.Failure.self)
            .flatMap {
                env.client.getFriendsList($0.apiKey, $0.steamID)
                    .zip(Just($0).setFailureType(to: SteamClient.Failure.self))
        }
        .flatMap { steamIDs, credentials in
            env.client.getProfiles(credentials.apiKey, steamIDs)
        }
        .catchToEffect()
        .map(AppAction.profilesLoaded)
        .receive(on: env.mainScheduler)
        .eraseToEffect()

    case .reloadFriendsList:
        return .none
        
    case .profilesLoaded(.success(let newFriendsList)):
        state.friendsList.complete(groupAndSortProfiles(newFriendsList))
        state.lastRefreshDate = env.date()
        return .none
        
    case .profilesLoaded(.failure(let error)):
        state.friendsList.fail(with: error.failureReason ?? "Failed to load the friends list.")
        return .none

    case .setupWindowAction(.credentialsSaved):
        state.setupWindowState = nil
        return Effect(value: .reloadFriendsList)

    case .setupWindowAction:
        return .none

    case .signOut:
        state = AppState()
        return Effect.running(env.credentialStore.clearCredentials)
            .map { AppAction.startSetupWindow }
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

                // People playing the same game are grouped together and sorted alphabetically.
                // Different games are then sorted alphabetically
            case (.some(let game), .some(let otherGame)) where game == otherGame:
                return profile.name < otherProfile.name
            case (.some(let game), .some(let otherGame)):
                return game < otherGame // This will group people playing the same game together

                // Sort people who aren't in a game but have the same sort ranking by most recently online
            case (.none, .none) where profile.lastOnlineTime != otherProfile.lastOnlineTime:
                return profile.lastOnlineTime > otherProfile.lastOnlineTime

            case (.none, .none):
                return profile.name < otherProfile.name
            }
        } else {
            return profile.status.sortRanking < otherProfile.status.sortRanking
        }
    }
}
