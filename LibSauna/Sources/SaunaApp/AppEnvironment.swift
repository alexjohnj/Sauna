import Foundation
import SaunaKit
import ComposableArchitecture

public struct AppEnvironment {
    public var app: AppClient
    public var client: SteamClient
    public var notifier: Notifier
    public var credentialStore: CredentialStore
    public var preferences: Preferences

    public var mainScheduler: AnySchedulerOf<DispatchQueue>
    public var date: () -> Date

    public init(
        app: AppClient,
        client: SteamClient,
        notifier: Notifier,
        credentialStore: CredentialStore,
        preferences: Preferences,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date
    ) {
        self.app = app
        self.client = client
        self.notifier = notifier
        self.credentialStore = credentialStore
        self.preferences = preferences
        self.mainScheduler = mainScheduler
        self.date = date
    }
}
