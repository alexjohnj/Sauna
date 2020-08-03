//
//  File.swift
//  
//
//  Created by Alex Jackson on 03/08/2020.
//

import Foundation

private let kUpdateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter
}()

extension FriendsListState {

    public var statusDescription: String {
        switch friendsList.state {
        case .notRequested:
            return ""

        case .idle(nil):
            if let lastRefreshDate = lastRefreshDate {
                return "Updated \(kUpdateTimeFormatter.string(from: lastRefreshDate))"
            } else {
                return ""
            }

        case .idle(let errorMessage?):
            return errorMessage

        case .loading:
            return "Updating…"
        }

    }

}
