//
//  ProfileRow.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import LibSauna

struct ProfileRow: View {

    let profile: Profile

    var body: some View {
        HStack {
            StatusView(status: profile.status)

            VStack(alignment: .leading, spacing: 0) {
                Text(profile.name)

                if let statusDescription = profile.statusDescription {
                    Text(statusDescription)
                        .foregroundColor(Color.secondary)
                        .font(.caption)
                }
            }
        }
        .padding([.top, .bottom])
    }
}
