//
//  FriendsListGroupEnvironmentValue.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 04/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI
import LibSauna

struct FriendsListGroupEnvironmentKey: EnvironmentKey {
    static var defaultValue: FriendsListSection.Group?
}

extension EnvironmentValues {
    var friendsListGroup: FriendsListSection.Group? {
        get {
            self[FriendsListGroupEnvironmentKey.self]
        }

        set {
            self[FriendsListGroupEnvironmentKey.self] = newValue
        }
    }
}
