//
//  SetupWindowStateTests.swift
//  SaunaTests
//
//  Created by Alex Jackson on 16/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import XCTest
import ComposableArchitecture

import LibSauna
@testable import Sauna

final class SetupWindowStateTests: XCTestCase {

    private let scheduler = DispatchQueue.testScheduler

    func test_doesNotSaveCredentials_whenCredentialsAreInvalid() {
        var environment = SetupWindowEnvironment.mock
        var savedCredentials: CredentialStore.Credentials?
        environment.credentialStore.saveCredentials = { savedCredentials = $0 }

        let store = TestStore(initialState: SetupWindowState(), reducer: setupWindowReducer, environment: environment)

        store.assert(
            .send(.steamIDChanged(SteamID.invalidRawID)) { $0.steamID = SteamID.invalidRawID },
            .send(.apiKeyChanged("")) { $0.apiKey = "" },
            .send(.doneButtonClicked)
        )

        XCTAssertNil(savedCredentials)
    }

    func test_savesCredentialsToCredentialStore() {
        var environment = SetupWindowEnvironment.mock
        var savedCredentials: CredentialStore.Credentials?
        environment.credentialStore.saveCredentials = { savedCredentials = $0 }

        let store = TestStore(initialState: SetupWindowState(), reducer: setupWindowReducer, environment: environment)

        store.assert(
            .send(.steamIDChanged(SteamID.valid.rawValue)) { $0.steamID = SteamID.valid.rawValue },
            .send(.apiKeyChanged(APIKey.valid.rawValue)) { $0.apiKey = APIKey.valid.rawValue },
            .send(.doneButtonClicked),
            .receive(.credentialsSaved(apiKey: APIKey.valid, steamID: SteamID.valid))
        )

        XCTAssertNotNil(savedCredentials)
    }

    func test_disablesDoneButton_whenEnteredDetailsAreInvalid() {
        var state = SetupWindowState()
        XCTAssertFalse(state.isDoneButtonEnabled)

        state.steamID = SteamID.valid.rawValue
        XCTAssertFalse(state.isDoneButtonEnabled)

        state.apiKey = APIKey.valid.rawValue
        XCTAssertTrue(state.isDoneButtonEnabled)

        state.steamID = "   "
        XCTAssertFalse(state.isDoneButtonEnabled)
    }

}

private extension SetupWindowEnvironment {
    static var mock: SetupWindowEnvironment {
        SetupWindowEnvironment(credentialStore: .mock)
    }
}
