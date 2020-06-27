//
//  HostingController.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

import ComposableArchitecture
import LibSauna

final class HostingController: WKHostingController<ContentView> {

    private let store: Store<WatchAppState, WatchAppAction>

    override init() {
        store = Store(
            initialState: WatchAppState(),
            reducer: watchAppReducer.debug(),
            environment: WatchAppEnvironment(
                mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
                date: Date.init,
                client: .live(.shared),
                credentialStore: .constant(steamID: kMySteamID, apiKey: kMySteamAPIKey)
            )
        )

        super.init()
    }

    override var body: ContentView {
        return ContentView(store: store)
    }
}
