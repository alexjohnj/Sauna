//
//  AppState.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var userID: SteamID
    var friendsList: Loadable<IdentifiedArray<SteamID, Profile>, String> = .notRequested
    var lastRefreshDate: Date?
}

enum AppAction: Equatable {
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
        state.friendsList = .loaded(IdentifiedArray(profiles))
        state.lastRefreshDate = env.date()
        return .none

    case .profilesLoaded(.failure(let error)):
        state.friendsList = .failed(error.failureReason ?? "Failed to load the friends list.")
        return .none
    }
}
.debug()
