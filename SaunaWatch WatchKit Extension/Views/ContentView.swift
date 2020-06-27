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
            Group {
                if viewStore.friendsListState.friendsList.isLoading {
                    Text("Loading Friends…")
                } else if viewStore.friendsListState.friendsList.isLoaded {
                    FriendsListView(store: store.scope(state: \.friendsListState, action: WatchAppAction.friendsListAction))
                } else {
                    Text("Failed to load friends")
                }
            }
            .onAppear { viewStore.send(.appAppeared) }
        }
    }
}
