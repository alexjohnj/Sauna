//
//  AppDelegate.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Cocoa
import SwiftUI

import ComposableArchitecture

final class AppDelegate: NSResponder, NSApplicationDelegate {

    var window: NSWindow!

    private var mainWindowController: MainWindowController!
    private var store: Store<AppState, AppAction>!
    private lazy var preferencesWindowController = PreferencesWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Preferences.standard.registerDefaults()

        // Create the SwiftUI view that provides the window contents.
        store = Store(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                client: .live(.shared),
                notifier: .user(.current()),
                credentialStore: .real,
                preferences: .standard,
                mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
                date: Date.init
            )
        )

        mainWindowController = MainWindowController(store: store)
        mainWindowController.showWindow(nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            mainWindowController.showWindow(nil)
            return false
        }

        return true
    }

    @objc private func signOut(_ sender: Any) {
        ViewStore(store).send(.signOut)
    }

    @objc private func openPreferences(_ sender: Any) {
        preferencesWindowController.showWindow(sender)
    }
}

// MARK: - Application Reducer

private let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
    appNotificationObserver.pullback(
        state: \AppState.loadedProfiles,
        action: /.`self`,
        environment: { AppNotificationEnvironment(notifier: $0.notifier, preferences: $0.preferences) }
    ),
    autoRefreshObserver.pullback(
        state: \.self,
        action: /.`self`,
        environment: { AutoRefreshReducerEnvironment(mainScheduler: $0.mainScheduler) }
    ),
    setupWindowReducer.optional.pullback(
        state: \AppState.setupWindowState,
        action: /AppAction.setupWindowAction,
        environment: { SetupWindowEnvironment(credentialStore: $0.credentialStore) }
    ),
    appStateReducer
)
