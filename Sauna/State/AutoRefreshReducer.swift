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
    case .reloadFriendsList where state.friendsList.isLoading == false:
        return Effect.cancel(id: RefreshTimerID())
    case .reloadFriendsList:
        return .none

    case .profilesLoaded:
        return Effect.timer(id: RefreshTimerID(), every: .seconds(kFriendsListRefreshInterval), on: env.mainScheduler)
            .map { _ in AppAction.reloadFriendsList }
            .eraseToEffect()
    
    case .windowLoaded:
        return .none
    }
}
