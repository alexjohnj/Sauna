//
//  ProfileDetailsView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 12/09/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import LibSauna

struct ProfileDetailsView: View {

    let profile: Profile

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ProfileDetailsHeaderView(profile: profile)

            Text("Recently Played")
                .font(.largeTitle)
                .fontWeight(.bold)

            ProgressView()

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = Profile.fixture(name: "AJ", realName: "Alex J", status: .online, currentGame: "Civ VI")
        return NavigationView {
            ProfileDetailsView(profile: profile)
        }
    }
}
