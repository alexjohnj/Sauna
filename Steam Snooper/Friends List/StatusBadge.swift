//
//  StatusBadge.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI

struct StatusBadge: View {
    
    let status: Profile.Status
    
    var color: Color {
        switch status {
        case .offline:
            return Color(NSColor.systemRed)
        case .online,
             .lookingToPlay,
             .lookingToTrade:
            return Color(NSColor.systemGreen)
        case .busy:
            return Color(NSColor.systemOrange)
        case .away:
            return Color(NSColor.systemBlue)
        case .snooze:
            return Color(NSColor.systemBlue)
        }
    }
    
    var body: some View {
        Circle()
            .foregroundColor(color)
    }
}
