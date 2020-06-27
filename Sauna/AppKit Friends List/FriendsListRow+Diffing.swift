//
//  FriendsListRow+Diffing.swift
//  Sauna
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import LibSauna
import Differ

extension FriendsListRow {
    static let equalityChecker: EqualityChecker<[FriendsListRow]> = { row, otherRow in
        switch (row, otherRow) {
        case (.groupHeader(let group), .groupHeader(let otherGroup)):
            return group == otherGroup

        case (.groupHeader, _):
            return false

        case (.friend(let profile), .friend(let otherProfile)):
            return profile.id == otherProfile.id

        case (.friend, _):
            return false
        }
    }
}
