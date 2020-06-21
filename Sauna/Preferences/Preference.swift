//
// Created by Alex Jackson on 20/11/2017.
// Copyright (c) 2017 Alex Jackson. All rights reserved.
//

import Foundation
import Combine

final class Preferences: ObservableObject {

    // MARK: - Nested Types

    struct NotificationPreferences: Equatable {
        let shouldNotifyWhenFriendsComeOnline: Bool
        let shouldNotifyWhenFriendsStartGames: Bool
    }

    // MARK: - Public Properties
    
    static let standard = Preferences(userDefaults: .standard)

    let objectWillChange: AnyPublisher<Void, Never>

    @Preference var shouldNotifyWhenFriendsComeOnline: Bool

    @Preference var shouldNotifyWhenFriendsStartGames: Bool

    var notificationPreferences: NotificationPreferences {
        NotificationPreferences(
            shouldNotifyWhenFriendsComeOnline: shouldNotifyWhenFriendsComeOnline,
            shouldNotifyWhenFriendsStartGames: shouldNotifyWhenFriendsStartGames
        )
    }

    // MARK: - Public Methods
    
    func registerDefaults() {
        // Registration is performed when the receiver is initalized!
    }

    // MARK: - Initializers

    init(userDefaults: UserDefaults) {
        self._shouldNotifyWhenFriendsStartGames = Preference(
            key: "AJJNotifyWhenFriendStartsGame",
            defaultValue: true,
            userDefaults: userDefaults
        )

        self._shouldNotifyWhenFriendsComeOnline = Preference(
            key: "AJJNotifyWhenFriendComesOnline",
            defaultValue: true,
            userDefaults: userDefaults
        )

        self.objectWillChange = NotificationCenter.default
          .publisher(for: UserDefaults.didChangeNotification, object: userDefaults)
          .map { _ in () }
          .eraseToAnyPublisher()
    }
}

// MARK: - Preference Property Wrapper

/// A value stored in `NSUserDefaults`.
///
/// A `Preference` specifies a key the value should be stored under in `NSUserDefaults` and a default value for the
/// preference. The default value is registered with `NSUserDefaults` the first time the property wrapper is created.
///
/// By default `Preference` instances will use the `standard` `NSUserDefaults` but a different instance can be passed
/// instead.
///
/// - Note: `T` must be a property list object.
///
@propertyWrapper
struct Preference<T> {

    let key: String

    var wrappedValue: T {
        get {
            getThunk(key)
        }

        set {
            setThunk(key, newValue)
        }
    }
    
    private let getThunk: (String) -> T
    private let setThunk: (String, T) -> Void

    private init(
        key: String,
        getThunk: @escaping (String) -> T,
        setThunk: @escaping (String, T) -> Void,
        registerThunk: (String) -> Void
    ) {
        self.key = key
        self.getThunk = getThunk
        self.setThunk = setThunk
            
        registerThunk(key)
    }
}

extension Preference where T: RawRepresentable {
    init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.init(
            key: key,
            getThunk: { T.init(rawValue: userDefaults.object(forKey: $0) as! T.RawValue) ?? defaultValue },
            setThunk: { userDefaults.set($1.rawValue, forKey: $0) },
            registerThunk: { userDefaults.register(defaults: [$0: defaultValue.rawValue]) })
    }
}

extension Preference where T == Bool {
    init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.init(
            key: key,
            getThunk: { userDefaults.bool(forKey: $0) },
            setThunk: { userDefaults.set($1, forKey: $0) },
            registerThunk: { userDefaults.register(defaults: [$0: defaultValue]) }
        )
    }
}

