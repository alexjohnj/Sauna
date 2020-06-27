//
//  SetupWindowStateTests.swift
//  SaunaTests
//
//  Created by Alex Jackson on 16/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import XCTest
import ComposableArchitecture
import UserNotifications

import LibSauna
@testable import Sauna

final class NotificationObserverTests: XCTestCase {

    private let scheduler = DispatchQueue.testScheduler

    func test_doesNotPostOnlineStatusNotification_whenInitiallyLoadingFriendsList() {
        var environment = AppNotificationEnvironment.mock
        var postedNotifications = [UNNotificationRequest]()
        environment.notifier.postNotifications = { postedNotifications.append(contentsOf: $0) }
        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        let secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), status: .offline)

        let store = TestStore(initialState: [], reducer: appNotificationObserver.reducer, environment: environment)
        store.assert(
            .send(.profilesLoaded(.success([firstProfile, secondProfile])))
        )

        XCTAssertTrue(postedNotifications.isEmpty)
    }

    func test_postsOnlineStatusNotification_whenAPlayerComesOnline() {
        var environment = AppNotificationEnvironment.mock
        var postedNotifications = [UNNotificationRequest]()
        environment.notifier.postNotifications = { postedNotifications.append(contentsOf: $0) }
        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        var secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), status: .offline)

        let store = TestStore(initialState: [firstProfile, secondProfile], reducer: appNotificationObserver.reducer, environment: environment)
        secondProfile.status = .online

        store.assert(
            .send(.profilesLoaded(.success([firstProfile, secondProfile])))
        )

        XCTAssertFalse(postedNotifications.isEmpty)
    }

    func test_postsGameNotification_whenAPlayerStartsPlayingAGame() throws {
        var environment = AppNotificationEnvironment.mock
        var postedNotifications = [UNNotificationRequest]()
        environment.notifier.postNotifications = { postedNotifications.append(contentsOf: $0) }
        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        var secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), name: "Player", status: .online, currentGame: nil)

        let store = TestStore(initialState: [firstProfile, secondProfile], reducer: appNotificationObserver.reducer, environment: environment)
        secondProfile.currentGame = "Borderlands"

        store.assert(
            .send(.profilesLoaded(.success([firstProfile, secondProfile])))
        )

        let notification = try XCTUnwrap(postedNotifications.first?.content)
        XCTAssertEqual(notification.title, "")
        XCTAssertEqual(notification.subtitle, "")
        XCTAssertEqual(notification.body, "Player is now playing Borderlands")
    }

    func test_doesNotPostDuplicateNotifications_whenAPlayerComesOnlineAndStartsPlayingAGame() {
        var environment = AppNotificationEnvironment.mock
        var postedNotifications = [UNNotificationRequest]()
        environment.notifier.postNotifications = { postedNotifications.append(contentsOf: $0) }
        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        var secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), status: .offline, currentGame: nil)

        let store = TestStore(initialState: [firstProfile, secondProfile], reducer: appNotificationObserver.reducer, environment: environment)
        secondProfile.status = .online
        secondProfile.currentGame = "Civilization VI"

        store.assert(
            .send(.profilesLoaded(.success([firstProfile, secondProfile])))
        )

        XCTAssertEqual(postedNotifications.count, 1)
    }

    func test_doesNotPostGameStartNotification_whenPlayerStartsPlayingAGame_AndGameNotificationsAreDisabled() {
        var environment = AppNotificationEnvironment.mock
        var postedNotifications = [UNNotificationRequest]()
        environment.notifier.postNotifications = { postedNotifications.append(contentsOf: $0) }
        environment.preferences.shouldNotifyWhenFriendsStartGames = false

        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        var secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), status: .online, currentGame: nil)

        let store = TestStore(initialState: [firstProfile, secondProfile], reducer: appNotificationObserver.reducer, environment: environment)
        secondProfile.currentGame = "Civilization VI"

        store.assert(
            .send(.profilesLoaded(.success([firstProfile, secondProfile])))
        )

        XCTAssertEqual(postedNotifications.count, 0)
    }

    func test_doesNotPostPlayerOnlineNotification_whenPlayerOnlineNotificationsAreDisabled() {
        var environment = AppNotificationEnvironment.mock
        var postedNotifications = [UNNotificationRequest]()
        environment.notifier.postNotifications = { postedNotifications.append(contentsOf: $0) }
        environment.preferences.shouldNotifyWhenFriendsComeOnline = false

        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        var secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), status: .offline, currentGame: nil)

        let store = TestStore(initialState: [firstProfile, secondProfile], reducer: appNotificationObserver.reducer, environment: environment)
        secondProfile.status = .online

        store.assert(
            .send(.profilesLoaded(.success([firstProfile, secondProfile])))
        )

        XCTAssertEqual(postedNotifications.count, 0)
    }

    func test_removesNotifications_associatedWithPlayersGoingOffline() throws {
        var environment = AppNotificationEnvironment.mock
        var removedNotificationIDs = [String]()
        environment.notifier.removeDeliveredNotifications = { removedNotificationIDs.append(contentsOf: $0) }
        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        var secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), status: .online)

        let store = TestStore(initialState: [firstProfile, secondProfile], reducer: appNotificationObserver.reducer, environment: environment)
        secondProfile.status = .offline
        store.assert(.send(.profilesLoaded(.success([firstProfile, secondProfile]))))

        let removedNotificationID = try XCTUnwrap(removedNotificationIDs.first)
        XCTAssertEqual(removedNotificationID, secondProfile.id.rawValue)
    }

    func test_removesNotifications_whenAPlayerStopsPlayingAGame() throws {
        var environment = AppNotificationEnvironment.mock
        var removedNotificationIDs = [String]()
        environment.notifier.removeDeliveredNotifications = { removedNotificationIDs.append(contentsOf: $0) }
        let firstProfile = Profile.fixture(id: .init(withoutChecking: "1"), status: .online)
        var secondProfile = Profile.fixture(id: .init(withoutChecking: "2"), status: .online, currentGame: "Borderlands 2")

        let store = TestStore(initialState: [firstProfile, secondProfile], reducer: appNotificationObserver.reducer, environment: environment)
        secondProfile.currentGame = nil
        store.assert(.send(.profilesLoaded(.success([firstProfile, secondProfile]))))

        let removedNotificationID = try XCTUnwrap(removedNotificationIDs.first)
        XCTAssertEqual(removedNotificationID, secondProfile.id.rawValue)
    }
}

private extension AppNotificationEnvironment {
    static var mock: AppNotificationEnvironment {
        AppNotificationEnvironment(
            notifier: .stub,
            preferences: Preferences(userDefaults: TemporaryUserDefaults(suiteName: #file)!)
        )
    }
}
