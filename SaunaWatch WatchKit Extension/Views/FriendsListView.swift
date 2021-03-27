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

import SaunaApp
import SaunaKit

struct FriendsListView: View {

    let store: Store<FriendsListState, FriendsListAction>

    var body: some View {
        WithViewStore(store) { (viewStore: ViewStore<FriendsListState, FriendsListAction>) in
            List {
                ForEach(viewStore.friendsList.data ?? [], id: \.group) { (section: FriendsListSection) in
                    Section(header: Text(section.group.localizedDescription)) {
                        ForEach(section.profiles) { profile in
                            ProfileRow(profile: profile)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { viewStore.send(.reload) }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
}
