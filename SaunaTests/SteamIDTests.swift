//
//  APIKeyTests.swift
//  SaunaTests
//
//  Created by Alex Jackson on 16/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import XCTest
@testable import Sauna

final class SteamIDTests: XCTestCase {
    func test_doesNotValidate_emptyKeys() {
        XCTAssertNil(SteamID(rawValue: ""))
        XCTAssertNil(SteamID(rawValue: "    "))
    }

    func test_doesNotValidate_idsThatAreTooLong() {
        XCTAssertNil(SteamID(rawValue: String(repeating: "1", count: 50)))
    }

    func test_doesNotValidate_idsThatAreTooShort() {
        XCTAssertNil(SteamID(rawValue: String(repeating: "1", count: 5)))
    }

    func test_doesNotValidate_idsThatContainCharacters() {
        XCTAssertNil(SteamID(rawValue: String(repeating: "a", count: SteamID.validIDLength)))
    }

    func test_stripsWhiteSpace_fromIDsThatAreOtherwiseValid() {
        var rawID = String(repeating: "1", count: SteamID.validIDLength)
        rawID.append("   ")

        XCTAssertNotNil(SteamID(rawValue: rawID))
    }
}
