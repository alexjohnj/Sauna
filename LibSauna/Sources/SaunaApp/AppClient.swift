//
//  File.swift
//  
//
//  Created by Alex Jackson on 31/05/2021.
//

import Foundation
import ComposableArchitecture
import Cocoa

public struct AppClient {
    public var terminate: () -> Effect<Never, Never>
}

extension AppClient {
    public static var live: AppClient {
        AppClient(
            terminate: {
                .fireAndForget {
                    NSApplication.shared.terminate(nil)
                }
            }
        )
    }
}

extension AppClient {
    public static var noop: AppClient {
        AppClient(
            terminate: { .none }
        )
    }
}
