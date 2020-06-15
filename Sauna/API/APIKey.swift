//
//  APIKey.swift
//  Sauna
//
//  Created by Alex Jackson on 15/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

struct APIKey: Hashable, RawRepresentable, Codable {
    let rawValue: String

    init?(rawValue: String) {
        let trimmedKey = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            return nil
        }

        self.rawValue = trimmedKey
    }
}

extension APIKey: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)!
    }
}

// MARK: - Test Data

#if DEBUG
extension APIKey {
    static let valid = APIKey(rawValue: "DEADBEEF")!
}
#endif
