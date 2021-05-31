//
// Created by Alex Jackson on 30/05/2021.
//

import Foundation
import SwiftUI

import ComposableArchitecture

public struct AppView: View {

    let store: Store<AppState, AppAction>
    @ObservedObject private var viewStore: ViewStore<AppState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        FriendsListView(store: store.scope(state: \.friendsListState, action: AppAction.friendsListAction))
          .frame(minWidth: 320, minHeight: 568)
          .sheet(
            isPresented: viewStore.binding(
              get: \.isSetupWindowPresented,
              send: .friendsListAction(.reload)
            ),
            content: {
                IfLetStore(
                  store.scope(state: \.setupWindowState, action: AppAction.setupWindowAction),
                  then: SetupWindowView.init(store:)
                )
            }
          )
    }
}
