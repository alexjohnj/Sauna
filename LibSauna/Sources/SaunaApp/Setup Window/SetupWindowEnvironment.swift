//
//  File.swift
//  
//
//  Created by Alex Jackson on 27/03/2021.
//

import Foundation
import SaunaKit

public struct SetupWindowEnvironment {
    public var credentialStore: CredentialStore

    public init(
        credentialStore: CredentialStore
    ) {
        self.credentialStore = credentialStore
    }
}
