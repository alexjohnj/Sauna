//
//  File.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

public struct SteamID: Hashable, RawRepresentable, Codable {

    // MARK: - Constants

    public static let validIDLength = 17

    private static let validIDPredicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]{17}$")

    // MARK: - Public Properties

    public let rawValue: String

    // MARK: - Initializers

    public init?(rawValue: String) {
        let trimmedID = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.validIDPredicate.evaluate(with: trimmedID) else { return nil }
        self.rawValue = trimmedID
    }
}

// MARK: - Test IDs

#if DEBUG
public extension SteamID {
    static let invalidRawID = "abc-123"
    static let valid = SteamID(rawValue: String(repeating: "0", count: SteamID.validIDLength))!

    init(withoutChecking rawValue: String) {
        self.rawValue = rawValue
    }
}
#endif
