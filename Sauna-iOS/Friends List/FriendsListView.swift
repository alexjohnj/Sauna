//
//  FriendsListView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import LibSauna

struct FriendsListView: View {

    let store: Store<FriendsListState, FriendsListAction>

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 70), spacing: 24, alignment: .top)
        ]
    }

    var body: some View {
        WithViewStore(store) { (vs: ViewStore<FriendsListState, FriendsListAction>) in
            ScrollView {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    ForEach(vs.friendsList.data ?? [], id: \.group) { section in
                        Section(header: FriendsListGroupHeader(group: section.group)) {
                            ForEach(section.profiles) { profile in
                                ProfileView(profile: profile)
                            }
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) { Text("Loading") }
            }
            .onAppear { vs.send(.reload) }
        }
    }
}
