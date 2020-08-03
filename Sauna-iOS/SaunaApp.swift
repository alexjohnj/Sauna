//
//  Sauna_iOSApp.swift
//  Sauna-iOS
//
//  Created by Alex Jackson on 03/08/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import LibSauna

@main
struct SaunaApp: App {

    private let store: Store<AppState, AppAction> = {
        print("here")
        return Store(
            initialState: AppState(),
            reducer: appReducer.debugActions(),
            environment: AppEnvironment(
                mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
                date: Date.init,
                client: .live(.shared),
                credentialStore: .constant(steamID: kMySteamID, apiKey: kMySteamAPIKey)
            )
        )
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
