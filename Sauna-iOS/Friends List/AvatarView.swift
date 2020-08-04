//
//  AvatarView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 04/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI
import LibSauna

struct AvatarView: View {

    let url: URL

    @StateObject private var image: RemoteImage
    @Environment(\.friendsListGroup) private var friendsListGroup: FriendsListSection.Group?

    init(url: URL) {
        self.url = url
        self._image = StateObject(wrappedValue: RemoteImage(url))
    }

    var body: some View {
        VStack {
            if let imageView = image.view {
                imageView
                    .resizable()
                    .cornerRadius(10)
                    .shadow(color: friendsListGroup?.glowColor ?? .clear, radius: 7)
                    .saturation(friendsListGroup?.saturationValue ?? 1)
            } else if image.isLoading {
                // FIXME: Would like to use a progress view here but it causes major jank when scrolling
                PlaceholderAvatarView()
            } else {
                PlaceholderAvatarView()
            }
        }
        .onAppear { image.startLoading() }
        .onDisappear { image.cancelLoading() }
    }
}

private extension FriendsListSection.Group {
    var glowColor: Color {
        switch self {
        case .inGame:
            return .green
        case .online:
            return .blue
        case .awayFromKeyboard:
            return .yellow
        case .offline:
            return .clear
        }
    }

    var saturationValue: Double {
        switch self {
        case .inGame,
             .online,
             .awayFromKeyboard:
            return 1
        case .offline:
            return 0
        }
    }
}
