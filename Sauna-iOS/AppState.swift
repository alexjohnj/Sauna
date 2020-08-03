//
//  SaunaAppState.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import ComposableArchitecture

import LibSauna

struct AppEnvironment {
    var mainScheduler: AnySchedulerOf<DispatchQueue>
    var date: () -> Date
    var client: SteamClient
    var credentialStore: CredentialStore
}

enum AppAction: Equatable {
    case friendsListAction(FriendsListAction)
}

struct AppState: Equatable {
    var friendsList = FriendsListState()
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    friendsListReducer.pullback(
        state: \.friendsList,
        action: /AppAction.friendsListAction,
        environment: {
            FriendsListEnvironment(
                mainScheduler: $0.mainScheduler,
                date: $0.date,
                client: $0.client,
                credentialStore: $0.credentialStore
            )
        }
    )
)
