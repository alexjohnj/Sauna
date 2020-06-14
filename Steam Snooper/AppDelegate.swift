//
//  AppDelegate.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Cocoa
import SwiftUI

import ComposableArchitecture

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var mainWindowController: MainWindowController!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let store = Store(
            initialState: AppState(userID: kMySteamID),
            reducer: appReducer,
            environment: AppEnvironment(
                client: .live(.shared),
                notifier: .user(.current()),
                mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
                date: Date.init
            )
        )

        mainWindowController = MainWindowController(store: store)
        mainWindowController.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            mainWindowController.showWindow(nil)
            return false
        }

        return true
    }
}

// MARK: - Application Reducer

private extension AppState {
    var loadedProfiles: [Profile] {
        friendsList.data?.compactMap(/FriendsListRow.friend) ?? []
    }
}

private let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
    appNotificationReducer.pullback(
        state: \AppState.loadedProfiles,
        action: /.`self`,
        environment: { AppNotificationEnvironment(notifier: $0.notifier) }
    ),
    appStateReducer
)
