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

@NSApplicationMain
final class AppDelegate: NSResponder, NSApplicationDelegate {
    
    var window: NSWindow!
    var mainWindowController: MainWindowController!
    var store: Store<AppState, AppAction>!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        store = Store(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                client: .live(.shared),
                notifier: .user(.current()),
                credentialStore: .real,
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
}

// MARK: - Application Reducer

private let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
    appNotificationReducer.pullback(
        state: \AppState.loadedProfiles,
        action: /.`self`,
        environment: { AppNotificationEnvironment(notifier: $0.notifier) }
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
