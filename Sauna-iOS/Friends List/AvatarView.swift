//
//  AvatarView.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 04/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI

struct AvatarView: View {

    let url: URL

    @StateObject private var image: RemoteImage

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
            } else if image.isLoading {
                ProgressView()
            } else {
                PlaceholderAvatarView()
            }
        }
        .onAppear { image.startLoading() }
        .onDisappear { image.cancelLoading() }
    }
}
