//
//  FriendTableViewCell.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 05/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Cocoa

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

    // MARK: - Private Methods

    private func configure(with profile: Profile) {
        nameLabel.stringValue = profile.name
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
        case .lookingToTrade:
            return "Looking to Trade"
        case .lookingToPlay:
            return "Looking to Play"
        default:
            return nil
        }
    }

    private func statusImage(for profile: Profile) -> NSImage {
        switch profile.status {
        case .online,
             .lookingToPlay,
             .lookingToTrade:
            return NSImage(named: NSImage.statusAvailableName)!

        case .snooze,
             .busy,
             .away:
            return NSImage(named: NSImage.statusPartiallyAvailableName)!

        case .offline:
            return NSImage(named: NSImage.statusUnavailableName)!
        }
    }
}
