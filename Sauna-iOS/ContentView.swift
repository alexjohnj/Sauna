//
//  ContentView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import LibSauna

struct ContentView: View {

    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            FriendsListView(store: store.scope(state: \.friendsList, action: AppAction.friendsListAction))
                .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
