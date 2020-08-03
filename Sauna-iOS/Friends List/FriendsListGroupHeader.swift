//
//  FriendsListSectionHeader.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import SwiftUI
import LibSauna

struct FriendsListGroupHeader: View {
    let group: FriendsListSection.Group

    var body: some View {
        Text(group.localizedDescription)
            .font(.title2)
            .fontWeight(.bold)
    }
}
