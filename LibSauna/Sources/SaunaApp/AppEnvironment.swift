import Foundation
import SaunaKit
import ComposableArchitecture

public struct AppEnvironment {
    public var client: SteamClient
    public var notifier: Notifier
    public var credentialStore: CredentialStore
    public var preferences: Preferences

    public var mainScheduler: AnySchedulerOf<DispatchQueue>
    public var date: () -> Date

    public init(
        client: SteamClient,
        notifier: Notifier,
        credentialStore: CredentialStore,
        preferences: Preferences,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date
    ) {
        self.client = client
        self.notifier = notifier
        self.credentialStore = credentialStore
        self.preferences = preferences
        self.mainScheduler = mainScheduler
        self.date = date
    }
}
