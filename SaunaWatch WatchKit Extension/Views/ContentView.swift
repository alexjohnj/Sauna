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
        WithViewStore(store) { viewStore in
            List {
                ForEach(viewStore.friendsListState.loadedProfiles) { profile in
                    ProfileRow(profile: profile)
                }
            }
            .onAppear { viewStore.send(.friendsListAction(.reload)) }
        }
    }
}
