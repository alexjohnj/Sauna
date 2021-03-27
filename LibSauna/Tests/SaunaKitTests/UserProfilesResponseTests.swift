//
//  UserProfilesResponseTests.swift
//  SaunaTests
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import XCTest

@testable import SaunaKit

final class UserProfilesResponseTests: XCTestCase {

    func test_decodingFixture() throws {
        let testData = try XCTUnwrap(testFixture.data(using: .utf8))
        let decoder = JSONDecoder()

        let decodedData = try decoder.decode(UserProfilesResponse.self, from: testData)

        XCTAssertEqual(decodedData.profiles.count, 3)
    }

}

private let testFixture = """
{
  "response": {
    "players": [
      {
        "steamid": "76561198007277374",
        "communityvisibilitystate": 3,
        "profilestate": 1,
        "personaname": "AJ",
        "profileurl": "https://steamcommunity.com/id/shadowhawk2008/",
        "avatar": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/86/86b7044bc7f2d0a3b3c49f6d996adb8d8e1f1138.jpg",
        "avatarmedium": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/86/86b7044bc7f2d0a3b3c49f6d996adb8d8e1f1138_medium.jpg",
        "avatarfull": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/86/86b7044bc7f2d0a3b3c49f6d996adb8d8e1f1138_full.jpg",
        "avatarhash": "86b7044bc7f2d0a3b3c49f6d996adb8d8e1f1138",
        "lastlogoff": 1591272212,
        "personastate": 0,
        "realname": "Alex",
        "primaryclanid": "103582791435860637",
        "timecreated": 1236187583,
        "personastateflags": 0,
        "loccountrycode": "GB",
        "locstatecode": "H3"
      },
      {
        "steamid": "76561198095538872",
        "communityvisibilitystate": 3,
        "profilestate": 1,
        "personaname": "REVILO",
        "profileurl": "https://steamcommunity.com/profiles/76561198095538872/",
        "avatar": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7c/7c05463cabaa0d97f1f39e6571556d8662e8c790.jpg",
        "avatarmedium": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7c/7c05463cabaa0d97f1f39e6571556d8662e8c790_medium.jpg",
        "avatarfull": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/7c/7c05463cabaa0d97f1f39e6571556d8662e8c790_full.jpg",
        "avatarhash": "7c05463cabaa0d97f1f39e6571556d8662e8c790",
        "lastlogoff": 1591263790,
        "personastate": 0,
        "realname": "Olly",
        "primaryclanid": "103582791435860637",
        "timecreated": 1372173349,
        "personastateflags": 0,
        "loccountrycode": "GB",
        "locstatecode": "H8"
      },
      {
        "steamid": "76561198103130086",
        "communityvisibilitystate": 3,
        "profilestate": 1,
        "personaname": "killercal",
        "profileurl": "https://steamcommunity.com/id/callump24/",
        "avatar": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/77/77f1e73eb51518c9126774759a30017489383b2a.jpg",
        "avatarmedium": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/77/77f1e73eb51518c9126774759a30017489383b2a_medium.jpg",
        "avatarfull": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/77/77f1e73eb51518c9126774759a30017489383b2a_full.jpg",
        "avatarhash": "77f1e73eb51518c9126774759a30017489383b2a",
        "lastlogoff": 1591226886,
        "personastate": 1,
        "realname": "Callum",
        "primaryclanid": "103582791435860637",
        "timecreated": 1376652188,
        "personastateflags": 0,
        "loccountrycode": "GB"
      }
    ]
  }
}
"""
