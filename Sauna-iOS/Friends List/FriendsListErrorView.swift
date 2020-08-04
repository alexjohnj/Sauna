//
//  FriendsListErrorView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 04/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI

struct FriendsListErrorView: View {

    let errorMessage: String
    let retry: () -> Void

    var body: some View {
        VStack {
            Text("Failed to load the friends list")
                .foregroundColor(Color.secondary)

            Text(errorMessage)
                .font(.footnote)
                .foregroundColor(Color.secondary)

            Button("Retry", action: retry)
        }
    }
}
