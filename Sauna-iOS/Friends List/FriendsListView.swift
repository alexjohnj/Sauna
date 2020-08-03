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

private let kRefreshInterval: TimeInterval = 60 * 2

struct FriendsListView: View {

    let store: Store<FriendsListState, FriendsListAction>
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

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
                ToolbarItem(placement: .bottomBar) {
                    Text(vs.statusDescription)
                        .font(.caption)
                }
            }
            .onAppear { vs.send(.reloadIfOlderThan(kRefreshInterval)) }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    vs.send(.reloadIfOlderThan(kRefreshInterval))
                }
            }
        }
    }
}
