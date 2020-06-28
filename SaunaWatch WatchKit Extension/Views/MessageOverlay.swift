//
//  MessageOverlay.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 28/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI

struct MessageOverlay: View {

    let message: String

    static let loading = MessageOverlay(message: "Loading…")

    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundColor(Color.secondary)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 62 / 255, green: 62 / 255, blue: 62 / 255))
                    .shadow(radius: 2)
            )
    }
}
