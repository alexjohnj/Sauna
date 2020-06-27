//
//  FriendTableViewCell.swift
//  Sauna
//
//  Created by Alex Jackson on 05/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Cocoa
import LibSauna

final class FriendTableViewCell: NSTableCellView {

    // MARK: - Outlets

    @IBOutlet private var nameLabel: NSTextField!
    @IBOutlet private var statusLabel: NSTextField!
    @IBOutlet private var statusImageView: NSImageView!

    // MARK: - Public Methods

    override var objectValue: Any? {
        didSet {
            assert(objectValue is Profile?)
            guard let profile = objectValue as? Profile else { return }
            configure(with: profile)
        }
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil {
            NSWorkspace.shared.notificationCenter.removeObserver(
                self,
                name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
                object: NSWorkspace.shared
            )
        } else if self.window == nil {
            NSWorkspace.shared.notificationCenter.addObserver(
                self,
                selector: #selector(displayAccessibilitySettingsDidChange(_:)),
                name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
                object: NSWorkspace.shared
            )
        }
    }

    // MARK: - Private Methods

    @objc private func displayAccessibilitySettingsDidChange(_ note: Notification) {
        if let profile = objectValue as? Profile {
            configure(with: profile)
        }
    }

    private func configure(with profile: Profile) {
        nameLabel.stringValue = profile.name
        toolTip = profile.realName
        statusImageView.image = statusImage(for: profile)

        if let statusText = self.statusText(for: profile) {
            statusLabel.stringValue = statusText
            statusLabel.isHidden = false
        } else {
            statusLabel.stringValue = ""
            statusLabel.isHidden = true
        }
    }

    private func statusText(for profile: Profile) -> String? {
        if let currentGame = profile.currentGame {
            return "Playing \(currentGame)"
        }

        switch profile.status {
        case .away:
            return "Away"
        case .busy:
            return "Busy"
        case .snooze:
            return "Snooze"
        case .lookingToTrade:
            return "Looking to Trade"
        case .lookingToPlay:
            return "Looking to Play"
        default:
            return nil
        }
    }

    private func statusImage(for profile: Profile) -> NSImage {
        let shouldDifferentiateWithoutColor = NSWorkspace.shared.accessibilityDisplayShouldDifferentiateWithoutColor

        switch profile.status {
        case .online,
             .lookingToPlay,
             .lookingToTrade:
            return shouldDifferentiateWithoutColor ?
                NSImage(named: "NSStatusAvailableFlat") ?? NSImage(named: NSImage.statusAvailableName)! :
                NSImage(named: NSImage.statusAvailableName)!

        case .snooze,
             .busy,
             .away:
            return shouldDifferentiateWithoutColor ?
                NSImage(named: "NSStatusPartiallyAvailableFlat") ?? NSImage(named: NSImage.statusPartiallyAvailableName)! :
                NSImage(named: NSImage.statusPartiallyAvailableName)!

        case .offline:
            return shouldDifferentiateWithoutColor ?
                NSImage(named: "NSStatusUnavailableFlat") ?? NSImage(named: NSImage.statusUnavailableName)! :
                NSImage(named: NSImage.statusUnavailableName)!
        }
    }
}
