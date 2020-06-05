//
//  MainWindowState.swift
//  Steam Snooper
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
    var statusText: String
    var isRefreshButtonEnabled: Bool
}

extension AppState {
    var mainWindowState: MainWindowState {
        let statusText: String
        if friendsList.isLoading {
            statusText = "Loading…"
        } else if friendsList.isLoaded,
            let refreshDate = lastRefreshDate {
            let formattedDate = kUpdateTimeFormatter.string(from: refreshDate)
            statusText = "Updated at \(formattedDate)"
        } else if let failureReason = friendsList.error {
            statusText = failureReason
        } else {
            statusText = ""
        }

        let isRefreshButtonEnabled = !friendsList.isLoading
        return MainWindowState(statusText: statusText, isRefreshButtonEnabled: isRefreshButtonEnabled)
    }
}
