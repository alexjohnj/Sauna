//
//  File.swift
//  
//
//  Created by Alex Jackson on 27/03/2021.
//

import Foundation
import SaunaKit

public struct SetupWindowEnvironment {

    public var app: AppClient
    public var credentialStore: CredentialStore

    public init(
        app: AppClient,
        credentialStore: CredentialStore
    ) {
        self.app = app
        self.credentialStore = credentialStore
    }
}
