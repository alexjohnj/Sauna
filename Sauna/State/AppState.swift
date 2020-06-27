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
import LibSauna

let kFriendsListRefreshInterval: TimeInterval = 2 * 60

struct AppState: Equatable {
    var friendsListState = FriendsListState()
    var setupWindowState: SetupWindowState?
}

enum AppAction: Equatable {
    case windowLoaded
    case startSetupWindow
    case signOut

    case setupWindowAction(SetupWindowAction)
    case friendsListAction(FriendsListAction)
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
            .map { $0 == nil ? AppAction.startSetupWindow : AppAction.friendsListAction(.reload) }
            .eraseToEffect()

    case .startSetupWindow:
        state.setupWindowState = SetupWindowState()
        return .none

    case .setupWindowAction(.credentialsSaved):
        state.setupWindowState = nil
        return Effect(value: .friendsListAction(.reload))

    case .setupWindowAction:
        return .none

    case .signOut:
        state = AppState()
        return Effect.running(env.credentialStore.clearCredentials)
            .map { AppAction.startSetupWindow }
            .eraseToEffect()

    case .friendsListAction:
        return .none
    }
}
