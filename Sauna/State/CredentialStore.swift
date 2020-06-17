//
//  CredentialStore.swift
//  Sauna
//
//  Created by Alex Jackson on 15/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

struct CredentialStore {
    typealias Credentials = (steamID: SteamID, apiKey: APIKey)
    
    var saveCredentials: (Credentials) -> Void
    var getCredentials: () -> Credentials?
    var clearCredentials: () -> Void
}

extension CredentialStore {
    static var mock: CredentialStore {
        var savedSteamID: SteamID?
        var savedAPIKey: APIKey?
        
        return CredentialStore(
            saveCredentials: { creds in
                savedSteamID = creds.steamID
                savedAPIKey = creds.apiKey
        },
            getCredentials: {
                guard let steamID = savedSteamID,
                    let apiKey = savedAPIKey else {
                        return nil
                }
                
                return (steamID, apiKey)
        },
            clearCredentials: {
                savedAPIKey = nil
                savedSteamID = nil
        })
    }
}

// MARK: - Keychain Implementation

extension CredentialStore {
    static var real: CredentialStore {
        CredentialStore(
            saveCredentials: saveCredentials(_:),
            getCredentials: Sauna.getCredentials,
            clearCredentials: Sauna.clearCredentials
        )
    }
}

import os.log

private let keychainLog = OSLog(subsystem: "org.alexj.Sauna", category: "Credential Store")
private let kSteamIDPreferenceKey = "AJJUserSteamID"
private let kAPIKeyService = "org.alexj.Sauna.SteamWebAPIKey"
private let kAPIKeyAccount = "webapi"

private var apiKeyKeychainQuery: [String: Any] {
    [
        kSecClass as String: kSecClassGenericPassword,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true,
        kSecAttrService as String: kAPIKeyService,
        kSecAttrAccount as String: kAPIKeyAccount
    ]
}

// MARK: - Saving

private func saveCredentials(_ credentials: CredentialStore.Credentials) {
    UserDefaults.standard.set(credentials.steamID.rawValue, forKey: kSteamIDPreferenceKey)
    saveAPIKey(credentials.apiKey)
}

private func saveAPIKey(_ key: APIKey) {
    let encodedKey = key.rawValue.data(using: .utf8)!

    if getAPIKey() != nil {
        let updateQuery = apiKeyKeychainQuery as CFDictionary
        let attributesToUpdate: [String: Any] = [kSecValueData as String: encodedKey]
        let status = SecItemUpdate(updateQuery, attributesToUpdate as CFDictionary)
        if status != errSecSuccess {
            os_log(.error, log: keychainLog, "Failed to update stored API key with code: %{errno}d", status)
        } else {
            os_log(.debug, log: keychainLog, "Updated saved API key in the keychain")
        }
    } else {
        let itemAttributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: kAPIKeyService,
            kSecAttrAccount as String: kAPIKeyAccount,
            kSecValueData as String: encodedKey
        ]
        let status = SecItemAdd(itemAttributes as CFDictionary, nil)
        if status != errSecSuccess {
            os_log(.error, log: keychainLog, "Failed to add API key to keychain with code: %{errno}d", status)
        } else {
            os_log(.debug, log: keychainLog, "Added new API key to the keychain")
        }
    }
}

// MARK: - Loading

private func getCredentials() -> CredentialStore.Credentials? {
    guard let savedUserID = UserDefaults.standard.string(forKey: kSteamIDPreferenceKey).flatMap(SteamID.init) else {
        return nil
    }

    guard let savedAPIkey = getAPIKey() else {
        return nil
    }

    return (savedUserID, savedAPIkey)
}

private func getAPIKey() -> APIKey? {
    let query = apiKeyKeychainQuery as CFDictionary
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query, &result)

    guard status == errSecSuccess,
        let itemData = result as? Data,
        let key = String(data: itemData, encoding: .utf8).flatMap(APIKey.init(rawValue:)) else {
            os_log(.error, log: keychainLog, "Failed to load credentials from keychain with code %{errno}d", status)
            return nil
    }

    return key
}

// MARK: - Deleting

private func clearCredentials() {
    UserDefaults.standard.removeObject(forKey: kSteamIDPreferenceKey)
    deleteSavedAPIKey()
}

private func deleteSavedAPIKey() {
    let status = SecItemDelete(apiKeyKeychainQuery as CFDictionary)
    if status != errSecSuccess {
        os_log(.error, log: keychainLog, "Failed to delete saved API key with error %{errno}d", status)
    } else {
        os_log(.debug, log: keychainLog, "Deleted saved API key from the keychain")
    }
}