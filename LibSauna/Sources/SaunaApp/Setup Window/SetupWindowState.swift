//
//  SetupWindowState.swift
//  Sauna
//
//  Created by Alex Jackson on 15/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine
import ComposableArchitecture

import SaunaKit
import TCAHelpers

public struct SetupWindowState: Equatable {
    public var steamID: String
    public var apiKey: String

    public var isDoneButtonEnabled: Bool {
        validatedSteamID != nil && validatedAPIKey != nil
    }

    fileprivate var validatedSteamID: SteamID? {
        SteamID(rawValue: steamID)
    }

    fileprivate var validatedAPIKey: APIKey? {
        APIKey(rawValue: apiKey)
    }

    public init(
        steamID: String = "",
        apiKey: String = ""
    ) {
        self.steamID = steamID
        self.apiKey = apiKey
    }
}

public enum SetupWindowAction: Equatable {
    case steamIDChanged(String)
    case apiKeyChanged(String)
    case doneButtonClicked
    case credentialsSaved(apiKey: APIKey, steamID: SteamID)
}

public let setupWindowReducer: Reducer<SetupWindowState, SetupWindowAction, SetupWindowEnvironment> = Reducer { state, action, env in
    switch action {
    case .apiKeyChanged(let newKey):
        state.apiKey = newKey
        return .none
    case .steamIDChanged(let newID):
        state.steamID = newID
        return .none

    case .doneButtonClicked:
        guard let steamID = state.validatedSteamID,
            let apiKey = state.validatedAPIKey else { return .none }

        return Effect.running { [state] in
            env.credentialStore.saveCredentials((steamID, apiKey))
            return SetupWindowAction.credentialsSaved(apiKey: apiKey, steamID: steamID)
        }

    case .credentialsSaved:
        return .none
    }
}
