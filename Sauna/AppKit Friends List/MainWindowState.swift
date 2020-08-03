//
//  MainWindowState.swift
//  Sauna
//
//  Created by Alex Jackson on 05/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

struct MainWindowState: Equatable {
    var title: String
    var bottomBarText: String
    var isRefreshButtonEnabled: Bool
}

extension AppState {
    var mainWindowState: MainWindowState {
        let onlineFriendCount = friendsListState.loadedProfiles.filter { $0.status.isTechnicallyOnline }.count
        let windowTitle = "Steam Friends (\(onlineFriendCount) Online)"
        
        let isRefreshButtonEnabled = !friendsListState.friendsList.isLoading
        return MainWindowState(
            title: windowTitle,
            bottomBarText: friendsListState.statusDescription,
            isRefreshButtonEnabled: isRefreshButtonEnabled
        )
    }
}
