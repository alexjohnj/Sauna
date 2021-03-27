//
//  SetupWindowController.swift
//  Sauna
//
//  Created by Alex Jackson on 15/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import AppKit
import Combine
import ComposableArchitecture
import SaunaApp

final class SetupWindowController: NSWindowController {

    // MARK: - Private Properties

    private let store: Store<SetupWindowState, SetupWindowAction>
    private let viewStore: ViewStore<SetupWindowState, SetupWindowAction>
    private var cancellationBag: [AnyCancellable] = []

    // MARK: - Outlets

    @IBOutlet private var steamIDField: NSTextField!
    @IBOutlet private var apiKeyField: NSTextField!
    @IBOutlet private var doneButton: NSButton!

    // MARK: - Initializers

    init(store: Store<SetupWindowState, SetupWindowAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(window: nil)
    }

    override var windowNibName: NSNib.Name? {
        "SetupWindowController"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(Self.self) does not implement \(#function)")
    }

    // MARK: - NSWindowController Overrides

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.preventsApplicationTerminationWhenModal = false

        viewStore.publisher.isDoneButtonEnabled
            .assign(to: \.isEnabled, on: self.doneButton)
            .store(in: &cancellationBag)

        NotificationCenter.default.publisher(for: NSTextField.textDidChangeNotification, object: steamIDField)
            .sink { [unowned self] _ in
                self.viewStore.send(.steamIDChanged(self.steamIDField.stringValue))
        }
        .store(in: &cancellationBag)

        NotificationCenter.default.publisher(for: NSTextField.textDidChangeNotification, object: apiKeyField)
            .sink { [unowned self] _ in
                self.viewStore.send(.apiKeyChanged(self.apiKeyField.stringValue))
        }
        .store(in: &cancellationBag)
    }

    // MARK: - Actions

    @IBAction private func done(_ sender: Any) {
        viewStore.send(.doneButtonClicked)
    }
}
