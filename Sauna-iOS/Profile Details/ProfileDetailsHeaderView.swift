//
//  ProfileDetailsHeaderView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 12/09/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import LibSauna

struct ProfileDetailsHeaderView: View {

    let profile: Profile

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Group {
                if let avatarURL = profile.avatarURL {
                    AvatarView(url: avatarURL)
                } else {
                    PlaceholderAvatarView()
                }
            }
            .frame(width: 128, height: 128)

            VStack(alignment: .leading) {
                Text(profile.name)
                    .font(.title)
                    .fontWeight(.bold)

                if let realName = profile.realName {
                    Text(realName)
                        .font(.title3)
                        .foregroundColor(Color.secondary)
                }

                if let statusText = statusText {
                    Text(statusText)
                        .font(.body)
                }
            }

            Spacer()
        }
    }

    private var statusText: String? {
        if case .offline = profile.status {
            return "Offline"
        } else {
            return profile.statusDescription
        }
    }
}

struct ProfileDetailsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = Profile.fixture(name: "Paradox Gods", realName: "Louis", status: .online, currentGame: "Civ VI")

        var offlineProfile = profile
        offlineProfile.status = .offline
        offlineProfile.currentGame = nil

        return Group {
            ProfileDetailsHeaderView(profile: profile)
            ProfileDetailsHeaderView(profile: offlineProfile)
        }
        .previewLayout(.sizeThatFits)
    }
}
