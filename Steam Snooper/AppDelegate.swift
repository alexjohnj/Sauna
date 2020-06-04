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


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let store = Store(
            initialState: AppState(userID: kMySteamID),
            reducer: appReducer,
            environment: AppEnvironment(
                client: .live(.shared),
                mainScheduler: DispatchQueue.main.eraseToAnyScheduler(),
                date: Date.init
            )
        )

        let contentView = ContentView(store: store)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)

        ViewStore(store).send(.reloadFriendsList)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

