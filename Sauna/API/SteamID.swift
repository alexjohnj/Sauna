//
//  File.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

struct SteamID: Hashable, RawRepresentable, Codable {
    let rawValue: String
}

extension SteamID: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}
