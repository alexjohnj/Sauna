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
    }
}
