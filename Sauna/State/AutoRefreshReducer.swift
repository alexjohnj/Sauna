//
//  AutoRefreshReducer.swift
//  Sauna
//
//  Created by Alex Jackson on 14/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct AutoRefreshReducerEnvironment {
    var mainScheduler: AnySchedulerOf<DispatchQueue>
}

let autoRefreshObserver: Observer<AppState, AppAction, AutoRefreshReducerEnvironment> = Observer { state, action, env in
    struct RefreshTimerID: Hashable { }
    
    switch action {
    case .friendsListAction(.reload) where state.friendsListState.friendsList.isLoading == false:
        return Effect.cancel(id: RefreshTimerID())

    case .friendsListAction(.reload):
        return .none

    case .friendsListAction(.profilesLoaded):
        return Effect.timer(id: RefreshTimerID(), every: .seconds(kFriendsListRefreshInterval), on: env.mainScheduler)
            .map { _ in AppAction.friendsListAction(.reload) }
            .eraseToEffect()

    case .signOut:
        return Effect.cancel(id: RefreshTimerID())

    default:
        return .none
    }
}
