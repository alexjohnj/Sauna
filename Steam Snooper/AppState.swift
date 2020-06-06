//
//  AppState.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import ComposableArchitecture

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
    }

    case friend(Profile)
    case groupHeader(Group)
}

struct AppState: Equatable {
    var userID: SteamID
    var friendsList: Loadable<[FriendsListRow], String> = .notRequested
    var lastRefreshDate: Date?
}

enum AppAction: Equatable {
    case windowAppeared
    case reloadFriendsList
    case profilesLoaded(Result<[Profile], SteamClient.Failure>)
}

struct AppEnvironment {
    var client: SteamClient
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var date: () -> Date
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer { state, action, env in
    switch action {
    case .windowAppeared where state.friendsList.isLoaded == false:
        return Effect(value: .reloadFriendsList)
    case .windowAppeared:
        return .none

    case .reloadFriendsList where state.friendsList.isLoading == false:
        state.friendsList = .loading
        return env.client.getFriendsList(state.userID)
            .flatMap(env.client.getProfiles)
            .catchToEffect()
            .map(AppAction.profilesLoaded)
            .receive(on: env.mainScheduler)
            .eraseToEffect()

    case .reloadFriendsList:
        return .none

    case .profilesLoaded(.success(let profiles)):
        state.friendsList = .loaded(sortProfiles(profiles))
        state.lastRefreshDate = env.date()
        return .none

    case .profilesLoaded(.failure(let error)):
        state.friendsList = .failed(error.failureReason ?? "Failed to load the friends list.")
        return .none
    }
}

// MARK: - Helper Functions

private func sortProfiles(_ profiles: [Profile]) -> [FriendsListRow] {
    let sortedProfiles = profiles.sorted { profile, otherProfile in
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

    struct Result {
        var currentGroup: FriendsListRow.Group?
        var groupedElements: [FriendsListRow] = []
    }

    let result = sortedProfiles.reduce(into: Result()) { result, profile in
        if result.currentGroup != profile.groupName {
            result.currentGroup = profile.groupName
            result.groupedElements.append(.groupHeader(profile.groupName))
        }

        result.groupedElements.append(.friend(profile))
    }

    return result.groupedElements
}

private extension Profile {
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
