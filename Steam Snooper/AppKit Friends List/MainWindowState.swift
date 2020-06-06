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
        switch friendsList.state {
        case .notRequested:
            statusText = ""

        case .idle(nil):
            if let lastRefreshDate = self.lastRefreshDate {
                statusText = "Updated \(kUpdateTimeFormatter.string(from: lastRefreshDate))"
            } else {
                statusText = ""
            }

        case .idle(let errorMessage?):
            statusText = errorMessage

        case .loading:
            statusText = "Updating…"
        }

        let isRefreshButtonEnabled = !friendsList.isLoading
        return MainWindowState(statusText: statusText, isRefreshButtonEnabled: isRefreshButtonEnabled)
    }
}
