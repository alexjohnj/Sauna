//
//  MainWindowController.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import AppKit
import Combine
import ComposableArchitecture

private let kRowIdentifier = NSUserInterfaceItemIdentifier("FriendTableColumn")

final class MainWindowController: NSWindowController {

    // MARK: - Private Properties

    private let store: Store<AppState, AppAction>
    private let viewStore: ViewStore<AppState, AppAction>

    private var cancellationBag: [AnyCancellable] = []

    // MARK: - Outlets

    @IBOutlet private var tableView: NSTableView!
    @IBOutlet private var refreshButton: NSButton!
    @IBOutlet private var statusLabel: NSTextField!

    // MARK: - Initializers

    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
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

        tableView.register(NSNib(nibNamed: "FriendTableViewCell", bundle: nil), forIdentifier: kRowIdentifier)

        viewStore.publisher.friendsList
            .sink { [unowned self] list in
                self.tableView.reloadData()
        }
        .store(in: &cancellationBag)

        viewStore.send(.windowAppeared)
    }
}

extension MainWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        viewStore.friendsList.data?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        viewStore.friendsList.data?[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        tableView.makeView(withIdentifier: kRowIdentifier, owner: nil) 
    }
}
