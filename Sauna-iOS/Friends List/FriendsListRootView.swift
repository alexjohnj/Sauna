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

struct FriendsListRootView: View {
    
    let store: Store<FriendsListState, FriendsListAction>
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    var body: some View {
        WithViewStore(store) { (vs: ViewStore<FriendsListState, FriendsListAction>) in
            FriendsListView(store: store)
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
