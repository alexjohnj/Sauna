//
//  MainWindowController.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Cocoa
import ComposableArchitecture

final class MainWindowController: NSWindowController {

    private let store: Store<AppState, AppAction>

    init(store: Store<AppState, AppAction>) {
        self.store = store
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(Self.self) does not implement \(#function)")
    }

    override var windowNibName: NSNib.Name? {
        "MainWindowController"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
