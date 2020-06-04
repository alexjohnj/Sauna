//
//  ProfileDecodingTests.swift
//  Steam SnooperTests
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import XCTest

@testable import Steam_Snooper

final class ProfileDecodingTests: XCTestCase {

    func test_decodingFixtureData() throws {
        let data = try XCTUnwrap(fixture.data(using: .utf8))
        let decoder = JSONDecoder()

        let decodedProfile = try decoder.decode(Profile.self, from: data)

        XCTAssertEqual(decodedProfile.id, "76561198007277374")
        XCTAssertEqual(decodedProfile.status, .offline)
        XCTAssertEqual(decodedProfile.name, "AJ")
    }

}

private let fixture = """
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
}
"""
