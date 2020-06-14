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

let appStateReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer { state, action, env in
    
    switch action {
    case .windowLoaded where state.friendsList.isLoaded == false:
        return Effect(value: .reloadFriendsList)
    case .windowLoaded:
        return .none
        
    case .reloadFriendsList where state.friendsList.isLoading == false:
        state.friendsList.startLoading()
        
        return env.client.getFriendsList(state.userID)
            .flatMap(env.client.getProfiles)
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
