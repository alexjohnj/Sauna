//
// Created by Alex Jackson on 30/05/2021.
// Copyright (c) 2021 Alex Jackson. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SaunaApp
import SwiftUI

@main
struct SaunaApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.store)
        }
    }
}

private let macAppReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
  appNotificationObserver.pullback(
    state: \AppState.friendsListState.loadedProfiles,
    action: /.`self`,
    environment: { AppNotificationEnvironment(notifier: $0.notifier, preferences: $0.preferences) }
  ),
  autoRefreshObserver.pullback(
    state: \.self,
    action: /.`self`,
    environment: { AutoRefreshReducerEnvironment(mainScheduler: $0.mainScheduler) }
  ),
  appReducer
)

final class AppDelegate: NSObject, NSApplicationDelegate {

    private(set) lazy var store: Store<AppState, AppAction> = Store(
      initialState: AppState(),
      reducer: macAppReducer,
      environment: AppEnvironment(
        client: .live(.shared),
        notifier: .user(.current()),
        credentialStore: .constant(steamID: kMySteamID, apiKey: kMySteamAPIKey),
        preferences: .standard,
        mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
        date: Date.init
      )
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.standard.registerDefaults()
    }
}
