//
//  StatusView.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import SaunaKit

struct StatusView: View {

    let status: Profile.Status

    private var iconColor: Color {
        switch status {
        case .online,
             .lookingToPlay,
             .lookingToTrade:
            return Color.green

        case .away,
             .busy,
             .snooze:
            return Color.orange

        case .offline:
            return Color.red
        }
    }

    var body: some View {
        Circle()
            .fill(iconColor)
            .frame(width: 8, height: 8)
    }
}
