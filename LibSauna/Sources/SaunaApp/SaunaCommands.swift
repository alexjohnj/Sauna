//
// Created by Alex Jackson on 31/05/2021.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct SaunaCommands: Commands {

    struct CommandState: Equatable {
        var isRefreshCommandDisabled: Bool
        var isSignOutCommandDisabled: Bool

        init(appState: AppState) {
            isRefreshCommandDisabled = appState.friendsListState.friendsList.isLoading || appState.isSetupWindowPresented
            isSignOutCommandDisabled = appState.isSetupWindowPresented
        }
    }

    let store: Store<AppState, AppAction>
    @ObservedObject private var viewStore: ViewStore<CommandState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: CommandState.init(appState:)))
    }

    // TODO: Menu item validation does not appear to be working. When using `CommandGroup`, changes to the CommandState
    // are not triggering a re-run of the body property. Changing `CommandGroup` to a custom `CommandMenu` fixes this,
    // but the validation still seems to be ignored.
    public var body: some Commands {
        CommandGroup(before: .saveItem) {
            Button("Refresh") { viewStore.send(.friendsListAction(.reload)) }
              .keyboardShortcut("r", modifiers: .command)
              .disabled(viewStore.isRefreshCommandDisabled)
        }

        CommandGroup(after: .appSettings) {
            Button("Sign Out…") { viewStore.send(.signOut) }
              .disabled(viewStore.isSignOutCommandDisabled)
        }
    }
}
