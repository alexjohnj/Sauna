//
//  FriendsListView.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI

import ComposableArchitecture

import LibSauna

struct FriendsListView: View {

    let store: Store<FriendsListState, FriendsListAction>

    var body: some View {
        WithViewStore(store) { (viewStore: ViewStore<FriendsListState, FriendsListAction>) in
            List {
                ForEach(viewStore.loadedProfiles) { profile in
                    ProfileRow(profile: profile)
                }
            }
            .contextMenu {
                Button(action: { viewStore.send(.reload) }) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                }
            }
        }
    }
}
