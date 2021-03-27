//
//  UserProfilesResponse.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

struct UserProfilesResponse: Codable {

    // MARK: - Nested Types

    private struct NestedResponse: Codable {
        let players: [Profile]
    }

    var profiles: [Profile] {
        response.players
    }

    // MARK: - Private Properties

    private let response: NestedResponse
}
