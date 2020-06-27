//
//  HostingController.swift
//  SaunaWatch WatchKit Extension
//
//  Created by Alex Jackson on 27/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

import ComposableArchitecture
import LibSauna

final class HostingController: WKHostingController<ContentView> {

    var store: Store<WatchAppState, WatchAppAction> {
        (WKExtension.shared().delegate as! ExtensionDelegate).store
    }

    override var body: ContentView {
        return ContentView(store: store)
    }
}
