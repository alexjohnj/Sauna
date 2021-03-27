//
//  AppState.swift
//  
//
//  Created by Alex Jackson on 27/03/2021.
//

import Foundation
import ComposableArchitecture

public struct AppState: Equatable {
    public var friendsListState: FriendsListState
    public var setupWindowState: SetupWindowState?
    
    public init(
        friendsListState: FriendsListState = FriendsListState(),
        setupWindowState: SetupWindowState? = nil
    ) {
        self.friendsListState = friendsListState
        self.setupWindowState = setupWindowState
    }
}

public enum AppAction: Equatable {
    case windowLoaded
    case startSetupWindow
    case signOut
    
    case setupWindowAction(SetupWindowAction)
    case friendsListAction(FriendsListAction)
}

public let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
    setupWindowReducer.optional().pullback(
        state: \AppState.setupWindowState,
        action: /AppAction.setupWindowAction,
        environment: { SetupWindowEnvironment(credentialStore: $0.credentialStore) }
    ),
    
    friendsListReducer.pullback(
        state: \AppState.friendsListState,
        action: /AppAction.friendsListAction,
        environment: {
            FriendsListEnvironment(
                mainScheduler: $0.mainScheduler,
                date: $0.date,
                client: $0.client,
                credentialStore: $0.credentialStore
            )
        }
    ),
    
    Reducer { state, action, env in
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
)
