//
//  WatchAppState.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import ComposableArchitecture
import LibSauna

private let kMinimumAutoRefreshInterval: TimeInterval = 60 * 2

typealias WatchAppEnvironment = FriendsListEnvironment

struct WatchAppState: Equatable {
    var friendsListState = FriendsListState()
}

enum WatchAppAction: Equatable {
    case appWillEnterForeground
    case friendsListAction(FriendsListAction)
}

let watchAppReducer: Reducer<WatchAppState, WatchAppAction, WatchAppEnvironment> = .combine(
    friendsListReducer.pullback(
        state: \WatchAppState.friendsListState,
        action: /WatchAppAction.friendsListAction,
        environment: { $0 }
    ),
    Reducer { state, action, env in
        switch action {
        case .appWillEnterForeground:
            if let lastRefreshDate = state.friendsListState.lastRefreshDate,
               env.date().timeIntervalSince(lastRefreshDate) < kMinimumAutoRefreshInterval {
                return .none
            }

            return Effect(value: .friendsListAction(.reload))

        case .friendsListAction:
            return .none
        }
    }
)
