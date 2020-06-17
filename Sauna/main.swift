//
//  main.swift
//  Sauna
//
//  Created by Alex Jackson on 17/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import AppKit

let isRunningInTest = NSClassFromString("XCTestCase") != nil

if isRunningInTest {
    let application = NSApplication.shared
    let delegate = TestAppDelegate()
    application.delegate = delegate
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
} else {
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
