//
//  FriendRow.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI

struct FriendView: View {

    let friendProfile: Profile

    private var statusText: String? {
        if let currentGame = friendProfile.currentGame { return currentGame }
        switch friendProfile.status {
        case .away:
            return "Away"
        case .busy:
            return "Busy"
        case .lookingToTrade:
            return "Looking to Trade"
        case .lookingToPlay:
            return "Looking to Play"
        default:
            return nil
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            StatusBadge(status: friendProfile.status)
                .frame(width: 16, height: 16)
            FriendDetailsView(name: friendProfile.name, statusText: statusText)
                .layoutPriority(1)
        }
    }
}

private struct FriendDetailsView: View {

    var name: String
    var statusText: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
            statusText.map {
                Text($0)
                    .foregroundColor(Color.secondary)
                    .controlSize(.small)
            }
        }
    }
}

