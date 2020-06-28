//
//  ContentView.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

    let store: Store<WatchAppState, WatchAppAction>

    var body: some View {
        WithViewStore(store) { (viewStore: ViewStore<WatchAppState, WatchAppAction>) in
            ZStack(alignment: .bottom) {
                FriendsListView(store: store.scope(state: \.friendsListState, action: WatchAppAction.friendsListAction))

                Group {
                    switch viewStore.friendsListState.friendsList.state {
                    case .notRequested,
                         .idle(nil):
                        EmptyView()
                    case .loading:
                        MessageOverlay.loading
                    case .idle(.some):
                        MessageOverlay(message: "Load Failed")
                    }
                }
                .transition(.move(edge: .bottom))
                .animation(.interactiveSpring())
            }
        }
    }
}
