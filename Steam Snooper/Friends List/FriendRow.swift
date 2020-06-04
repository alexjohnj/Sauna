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

            VStack(alignment: .leading) {
                Text(friendProfile.name)
                statusText.map {
                    Text($0)
                        .foregroundColor(Color.secondary)
                        .controlSize(.small)
                }
            }
            .layoutPriority(1)
        }
    }
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FriendView(friendProfile: .fixture())
            FriendView(friendProfile: .fixture(status: .offline, currentGame: nil))
            FriendView(friendProfile: .fixture(status: .away, currentGame: nil))
        }
        .padding()
    }
}
