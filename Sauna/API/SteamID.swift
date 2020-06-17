//
//  File.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

struct SteamID: Hashable, RawRepresentable, Codable {

    // MARK: - Constants

    static let validIDLength = 17

    private static let validIDPredicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]{17}$")

    // MARK: - Public Properties

    let rawValue: String

    // MARK: - Initializers

    init?(rawValue: String) {
        let trimmedID = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.validIDPredicate.evaluate(with: trimmedID) else { return nil }
        self.rawValue = trimmedID
    }
}

extension SteamID: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)!
    }
}

// MARK: - Test IDs

#if DEBUG
extension SteamID {
    static let invalidRawID = "abc-123"
    static let valid = SteamID(rawValue: String(repeating: "0", count: SteamID.validIDLength))!
}
#endif