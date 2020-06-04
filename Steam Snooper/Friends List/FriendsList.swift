//
//  FriendsList.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import AppKit
import SwiftUI

struct FriendsList: View {

    let friends: [Profile]

    var body: some View {
        List(Array(friends.enumerated()), id: \.1.id) { (index, friendProfile) in
            VStack(alignment: .leading, spacing: 16) {
                FriendView(friendProfile: friendProfile)
                Divider()
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
    }
}
