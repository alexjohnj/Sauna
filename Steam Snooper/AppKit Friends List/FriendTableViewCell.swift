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
        statusLabel.stringValue = profile.currentGame ?? ""
        statusLabel.isHidden = profile.currentGame == nil
    }
}
