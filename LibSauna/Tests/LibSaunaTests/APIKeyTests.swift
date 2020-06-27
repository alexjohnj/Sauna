//
//  APIKeyTests.swift
//  SaunaTests
//
//  Created by Alex Jackson on 16/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import XCTest
@testable import LibSauna

final class APIKeyTests: XCTestCase {
    func test_doesNotValidate_emptyKeys() {
        XCTAssertNil(APIKey(rawValue: ""))
        XCTAssertNil(APIKey(rawValue: "    "))
    }

    func test_validatesNonEmptyKeys() {
        XCTAssertNotNil(APIKey("abc-123"))
    }

    func test_stripsWhitespaceFromValidatedKeys() {
        let key = APIKey(rawValue: "abc-123   ")
        XCTAssertNotNil(key)
        XCTAssertEqual(key?.rawValue, "abc-123")
    }
}
