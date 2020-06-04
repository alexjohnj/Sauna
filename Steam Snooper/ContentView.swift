//
//  ContentView.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { (viewStore: ViewStore<AppState, AppAction>) in
            Group {
                if viewStore.friendsList.isLoading {
                    Text("Loading Friends…")
                        .foregroundColor(.secondary)
                        .padding()
                } else if viewStore.friendsList.error != nil {
                    Text(viewStore.friendsList.error!)
                        .foregroundColor(.secondary)
                        .padding()
                } else if viewStore.friendsList.data != nil {
                    FriendsList(friends: viewStore.friendsList.data!.elements)
                }
            }
            .frame(minWidth: 400, maxWidth: 400, maxHeight: .infinity)
            .onAppear { viewStore.send(.windowAppeared) }
        }
    }
}
