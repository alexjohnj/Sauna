//
//  File.swift
//
//
//  Created by Alex Jackson on 31/05/2021.
//

import Foundation
import SwiftUI

public struct SettingsWindowView: View {

    @ObservedObject private var preferences: Preferences = .standard

    public init() { }

    public var body: some View {
        Form {
            HStack(alignment: .firstTextBaseline) {
                Text("Notifications:")

                VStack(alignment: .leading) {
                    Toggle("Notify me when a friend comes online", isOn: $preferences.shouldNotifyWhenFriendsComeOnline)
                    Toggle("Notify me when a friend launches a game", isOn: $preferences.shouldNotifyWhenFriendsStartGames)
                }
            }
        }
        .padding()
    }
}
