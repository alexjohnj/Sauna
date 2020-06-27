//
//  MainWindowState.swift
//  Sauna
//
//  Created by Alex Jackson on 05/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

private let kUpdateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter
}()

struct MainWindowState: Equatable {
    var title: String
    var statusText: String
    var isRefreshButtonEnabled: Bool
}

extension AppState {
    var mainWindowState: MainWindowState {
        let statusText: String
        switch friendsListState.friendsList.state {
        case .notRequested:
            statusText = ""
            
        case .idle(nil):
            if let lastRefreshDate = friendsListState.lastRefreshDate {
                statusText = "Updated \(kUpdateTimeFormatter.string(from: lastRefreshDate))"
            } else {
                statusText = ""
            }
            
        case .idle(let errorMessage?):
            statusText = errorMessage
            
        case .loading:
            statusText = "Updating…"
        }
        
        let onlineFriendCount = friendsListState.loadedProfiles.filter { $0.status.isTechnicallyOnline }.count
        let windowTitle = "Steam Friends (\(onlineFriendCount) Online)"
        
        let isRefreshButtonEnabled = !friendsListState.friendsList.isLoading
        return MainWindowState(
            title: windowTitle,
            statusText: statusText,
            isRefreshButtonEnabled: isRefreshButtonEnabled
        )
    }
}
