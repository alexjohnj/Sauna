//
//  ProfileView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI
import LibSauna

struct ProfileView: View {

    let profile: Profile

    var body: some View {
        VStack(alignment: .center) {
            Group {
                if let avatarURL = profile.avatarURL {
                    AvatarView(url: avatarURL)
                } else {
                    PlaceholderAvatarView()
                }
            }
            .aspectRatio(1, contentMode: .fit)

            Text(profile.name)
                .font(.caption)

            if let statusDescription = profile.statusDescription {
                Text(statusDescription)
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
            }
        }
        .lineLimit(4)
        .multilineTextAlignment(.center)
    }

}
