//
//  MainWindowController.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import AppKit
import Combine
import ComposableArchitecture
import Differ

// MARK: - Constants

private let kRowIdentifier = NSUserInterfaceItemIdentifier("FriendTableColumn")
private let kGroupRowIdentifier = NSUserInterfaceItemIdentifier("FriendsGroupRow")

private let kGroupHeaderRowHeight: CGFloat = 24
private let kFriendRowHeight: CGFloat = 48

final class MainWindowController: NSWindowController, NSMenuItemValidation {

    // MARK: - Private Properties

    private let store: Store<AppState, AppAction>
    private let viewStore: ViewStore<AppState, AppAction>

    private var cancellationBag: [AnyCancellable] = []
    private var setupWindowController: SetupWindowController?

    // MARK: - Outlets

    @IBOutlet private var tableView: NSTableView!
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
        tableView.rowHeight = kFriendRowHeight
        tableView.target = self
        tableView.doubleAction = #selector(openSelectedProfile(_:))

        viewStore.publisher.friendsList
            .scan(([FriendsListRow](), [FriendsListRow]())) { accum, newList in
                (accum.1, newList.data ?? [])
            }
            .sink { [unowned self] (oldList, newList) in
                self.tableView.beginUpdates()
                self.tableView.animateRowChanges(
                    oldData: oldList,
                    newData: newList,
                    isEqual: FriendsListRow.equalityChecker,
                    deletionAnimation: .slideUp,
                    insertionAnimation: .slideDown
                )

                // This is inefficient but is needed since the diffs do not say which rows need to be reloaded.
                let rowIndicesToReload = IndexSet(integersIn: 0..<newList.count)
                self.tableView.reloadData(forRowIndexes: rowIndicesToReload, columnIndexes: [0])
                self.tableView.noteHeightOfRows(withIndexesChanged: rowIndicesToReload)
                self.tableView.endUpdates()
        }
        .store(in: &cancellationBag)

        store.scope(state: { $0.setupWindowState }, action: AppAction.setupWindowAction)
            .ifLet(
                then: { [unowned self] setupWindowStore in
                    self.setupWindowController = SetupWindowController(store: setupWindowStore)
                    self.window?.beginSheet(self.setupWindowController!.window!) { _ in self.setupWindowController = nil }
                },
                else: { [unowned self] in
                    if let setupWindow = self.setupWindowController?.window {
                        self.window?.endSheet(setupWindow, returnCode: .OK)
                    }
                }
        )
            .store(in: &cancellationBag)

        let windowState = viewStore.publisher.mainWindowState

        windowState.statusText
            .removeDuplicates()
            .throttle(for: .seconds(0.5), scheduler: RunLoop.main, latest: true)
            .assign(to: \.statusLabel.stringValue, on: self)
            .store(in: &cancellationBag)

        windowState.title
            .sink { [unowned self] title in self.window?.title = title }
            .store(in: &cancellationBag)

        viewStore.send(.windowLoaded)
    }

    // MARK: - Actions

    @objc private func openSelectedProfile(_ sender: Any) {
        guard tableView.clickedRow != -1,
            case .friend(let profile) = viewStore.friendsList.data?[tableView.clickedRow] else {
                return
        }

        NSWorkspace.shared.open(profile.url)
    }

    // MARK: - Menu Items

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(refresh(_:)) {
            return viewStore.mainWindowState.isRefreshButtonEnabled
        } else if menuItem.action == #selector(copy(_:)) {
            return canCopySelectedRow()
        } else {
            return true
        }
    }

    @objc private func copy(_ sender: Any) {
        guard tableView.selectedRow != -1,
            case .friend(let selectedProfile)? = viewStore.friendsList.data?[tableView.selectedRow] else {
                return
        }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(selectedProfile.url.absoluteString, forType: .string)
    }

    @objc private func refresh(_ sender: Any) {
        viewStore.send(.reloadFriendsList)
    }

    // MARK: - Helper Methods

    private func canCopySelectedRow() -> Bool {
        guard tableView.selectedRow != -1,
            case .friend? = viewStore.friendsList.data?[tableView.selectedRow] else {
                return false
        }

        return true
    }
}

extension MainWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        viewStore.friendsList.data?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if case .groupHeader? = viewStore.friendsList.data?[row] {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        switch viewStore.friendsList.data?[row] {
        case .friend(let profile):
            return profile
        default:
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if case .groupHeader(let group)? = viewStore.friendsList.data?[row] {
            let headerView = tableView.makeView(withIdentifier: kGroupRowIdentifier, owner: self) as! FriendTableViewGroupCell
            headerView.titleLabel?.stringValue = group.localizedDescription
            return headerView
        } else {
            return tableView.makeView(withIdentifier: kRowIdentifier, owner: self)
        }
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if case .groupHeader = viewStore.friendsList.data?[row] {
            return kGroupHeaderRowHeight
        } else {
            return kFriendRowHeight
        }
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if case .groupHeader = viewStore.friendsList.data?[row] {
            return false
        } else {
            return true
        }
    }
}
