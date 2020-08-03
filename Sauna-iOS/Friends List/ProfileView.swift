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
            if let avatarURL = profile.avatarURL {
                AvatarView(url: avatarURL)
                    .frame(width: 69, height: 69)
            } else {
                PlaceholderAvatarView()
                    .frame(width: 69, height: 69)
            }

            Text(profile.name)
                .font(.caption)

            if let statusDescription = profile.statusDescription {
                Text(statusDescription)
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
            }
        }
        .lineLimit(2)
        .multilineTextAlignment(.center)
    }

}
