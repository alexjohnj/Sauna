//
//  File.swift
//  Steam SnooperTests
//
//  Created by Alex Jackson on 14/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine

import ComposableArchitecture
@testable import Steam_Snooper

extension AppEnvironment {
    static let mock: (AnySchedulerOf<DispatchQueue>) -> AppEnvironment = { scheduler in
        AppEnvironment(
            client: .stub,
            notifier: .stub,
            mainScheduler: scheduler,
            date: { Date.stub }
        )
    }
}

extension SteamClient {
    static var stub: SteamClient {
        SteamClient(
            getFriendsList: { _ in
                stubPublisher([])
        }, getProfiles: { _ in
            stubPublisher([])
        })
    }
}

extension Notifier {
    static var stub: Notifier {
        Notifier(requestAuthorization: { }, postNotifications: { _ in }, removeDeliveredNotifications: { _ in })
    }
}

extension Date {
    static var stub: Date {
        Date(timeIntervalSince1970: 86400)
    }
}

private func stubPublisher<T, Failure: Error>(_ value: T) -> AnyPublisher<T, Failure> {
    Just(value)
        .setFailureType(to: Failure.self)
        .eraseToAnyPublisher()
}

