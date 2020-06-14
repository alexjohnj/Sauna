//
//  Observer.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 14/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import ComposableArchitecture

/// A reducer that operates on an immutable copy of the state.
///
/// Useful for running side-effects in response to actions.
///
struct Observer<State, Action, Environment> {
    
    private let observer: (State, Action, Environment) -> Effect<Action, Never>
    
    init(_ observer: @escaping (State, Action, Environment) -> Effect<Action, Never>) {
        self.observer = observer
    }
    
    func run(_ state: State, _ action: Action, _ environment: Environment) -> Effect<Action, Never> {
        self.observer(state, action, environment)
    }
    
    /// Converts an observer that observes local state into an immutable reducer that operates on global state.
    ///
    func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
        state toLocalState: KeyPath<GlobalState, State>,
        action toLocalAction: CasePath<GlobalAction, Action>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
    ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
        Reducer { globalState, globalAction, globalEnvironment in
            guard let localAction = toLocalAction.extract(from: globalAction) else { return .none }
            return self.observer(
                globalState[keyPath: toLocalState],
                localAction,
                toLocalEnvironment(globalEnvironment)
            )
                .map(toLocalAction.embed)
        }
    }
}
