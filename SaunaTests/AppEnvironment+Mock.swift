//
//  File.swift
//  SaunaTests
//
//  Created by Alex Jackson on 14/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine

import ComposableArchitecture
@testable import Sauna

class TemporaryUserDefaults: UserDefaults {

    let suiteName: String

    override init?(suiteName: String?) {
        self.suiteName = suiteName ?? UUID().uuidString
        super.init(suiteName: suiteName)

        removePersistentDomain(forName: self.suiteName)
    }

    deinit {
        removePersistentDomain(forName: suiteName)
    }
}

extension AppEnvironment {
    static let mock: (AnySchedulerOf<DispatchQueue>) -> AppEnvironment = { scheduler in
        AppEnvironment(
            client: .stub,
            notifier: .stub,
            credentialStore: .stub,
            preferences: Preferences(userDefaults: TemporaryUserDefaults(suiteName: "org.alexj.Sauna.TestUserDefaults")!),
            mainScheduler: scheduler,
            date: { Date.stub }
        )
    }
}

extension SteamClient {
    static var stub: SteamClient {
        SteamClient(
            getFriendsList: { _, _  in
                stubPublisher([])
        }, getProfiles: { _, _  in
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

extension CredentialStore {
    static var stub: CredentialStore {
        CredentialStore(saveCredentials: { _ in }, getCredentials: { nil }, clearCredentials: { })
    }
}

private func stubPublisher<T, Failure: Error>(_ value: T) -> AnyPublisher<T, Failure> {
    Just(value)
        .setFailureType(to: Failure.self)
        .eraseToAnyPublisher()
}

