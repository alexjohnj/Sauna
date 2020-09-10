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
import FetchImage

struct AvatarView: View {

    let url: URL

    @StateObject private var image: FetchImage
    @Environment(\.friendsListGroup) private var friendsListGroup: FriendsListSection.Group?

    init(url: URL) {
        self.url = url
        self._image = StateObject(wrappedValue: FetchImage(url: url))
    }

    var body: some View {
        ZStack {
            PlaceholderAvatarView()
            image.view?
                .resizable()
                .cornerRadius(10)
                .shadow(color: friendsListGroup?.glowColor ?? .clear, radius: 7)
                .saturation(friendsListGroup?.saturationValue ?? 1)
        }
        .animation(.default)
        .onAppear(perform: image.fetch)
        .onDisappear(perform: image.cancel)
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
