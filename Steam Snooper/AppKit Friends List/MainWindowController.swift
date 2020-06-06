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
private let kGroupRowIdentifier = NSUserInterfaceItemIdentifier("FriendsGroupRow")

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
        tableView.register(NSNib(nibNamed: "FriendTableViewGroupCell", bundle: nil), forIdentifier: kGroupRowIdentifier)

        viewStore.publisher.friendsList
            .sink { [unowned self] list in
                self.tableView.reloadData()
        }
        .store(in: &cancellationBag)

        let windowState = viewStore.publisher.mainWindowState
        windowState.statusText.assign(to: \.statusLabel.stringValue, on: self)
            .store(in: &cancellationBag)
        windowState.isRefreshButtonEnabled.assign(to: \.refreshButton.isEnabled, on: self)
            .store(in: &cancellationBag)

        viewStore.send(.windowAppeared)
    }

    // MARK: - Actions

    @IBAction private func refresh(_ sender: Any) {
        viewStore.send(.reloadFriendsList)
    }
}

extension MainWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        viewStore.friendsList.data?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if case .right? = viewStore.friendsList.data?[row] {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        switch viewStore.friendsList.data?[row] {
        case .left(let profile):
            return profile
        case .right(let group):
            return group.title
        case .none:
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if case .right(let group)? = viewStore.friendsList.data?[row] {
            let headerView = tableView.makeView(withIdentifier: kGroupRowIdentifier, owner: self) as! FriendTableViewGroupCell
            headerView.titleLabel?.stringValue = group.title
            return headerView
        } else {
            return tableView.makeView(withIdentifier: kRowIdentifier, owner: self)
        }
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if case .right = viewStore.friendsList.data?[row] {
            return tableView.rowHeight
        } else {
            return 48
        }
    }
}
