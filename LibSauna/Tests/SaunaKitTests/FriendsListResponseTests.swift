//
//  FriendsListResponseTests.swift
//  SaunaTests
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import XCTest

@testable import SaunaKit

final class FriendsListResponseTests: XCTestCase {

    func test_decodingFixture() throws {
        let testData = try XCTUnwrap(testFixture.data(using: .utf8))
        let decoder = JSONDecoder()

        let decodedData = try decoder.decode(FriendsListResponse.self, from: testData)

        XCTAssertEqual(decodedData.friends.count, 2)
    }

}

private let testFixture = """
{
  "friendslist": {
    "friends": [
      {
        "steamid": "76561197775614831",
        "relationship": "friend",
        "friend_since": 1368799992
      },
      {
        "steamid": "76562197995836411",
        "relationship": "friend",
        "friend_since": 1402348919
      }
    ]
  }
}
"""
