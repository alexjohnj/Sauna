//
//  FriendsListState.swift
//  Sauna
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine

import ComposableArchitecture

public struct FriendsListEnvironment {
    public var mainScheduler: AnySchedulerOf<DispatchQueue>
    public var date: () -> Date

    public var client: SteamClient
    public var credentialStore: CredentialStore

    public init(
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date,
        client: SteamClient,
        credentialStore: CredentialStore
    ) {
        self.mainScheduler = mainScheduler
        self.date = date
        self.client = client
        self.credentialStore = credentialStore
    }
}

public struct FriendsListState: Equatable {
    public var friendsList = Loadable<[FriendsListSection], String>()
    public var lastRefreshDate: Date?

    public var loadedProfiles: [Profile] {
        friendsList.data?.flatMap(\.profiles) ?? []
    }

    public init() { }
}

public enum FriendsListAction: Equatable {
    case reload
    case reloadIfOlderThan(TimeInterval)
    case profilesLoaded(Result<[Profile], SteamClient.Failure>)
}

public let friendsListReducer: Reducer<FriendsListState, FriendsListAction, FriendsListEnvironment> = Reducer { state, action, env in
    switch action {
    case .reloadIfOlderThan(let timeInterval) where state.friendsList.isLoading == false:
        guard let lastRefreshDate = state.lastRefreshDate else {
            return Effect(value: .reload)
        }

        guard env.date().timeIntervalSince(lastRefreshDate) >= timeInterval else {
            return .none
        }

        return Effect(value: .reload)

    case .reloadIfOlderThan:
        return .none

    case .reload where state.friendsList.isLoading == false:
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
            .map(FriendsListAction.profilesLoaded)
            .receive(on: env.mainScheduler)
            .eraseToEffect()

    case .reload:
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

private func groupAndSortProfiles(_ profiles: [Profile]) -> [FriendsListSection] {
    return Dictionary<FriendsListSection.Group, [Profile]>(grouping: profiles, by: \.groupName)
        .mapValues(sortProfiles) // Sort contents of each group
        .sorted { $0.key.sortRanking < $1.key.sortRanking } // Sort groups
        .map(FriendsListSection.init)
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
