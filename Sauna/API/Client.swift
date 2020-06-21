//
//  Client.swift
//  Sauna
//
//  Created by Alex Jackson on 04/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine
import Requests

struct SteamAPI: RequestProviding {

    let baseURL = URL("https://api.steampowered.com")
    var apiKey: APIKey

    func getFriendsList(forPlayerID steamID: SteamID) -> Request<SteamAPI, FriendsListResponse> {
        get(.json(encoded: FriendsListResponse.self), from: "ISteamUser/GetFriendList/v0001/")
            .adding(queryItems: ["key": apiKey.rawValue, "steamid": steamID.rawValue, "relationship": "friend"])
    }

    func getProfiles(forIDs steamIDs: [SteamID]) -> Request<SteamAPI, UserProfilesResponse> {
        let allSteamIDs = steamIDs.map(\.rawValue).joined(separator: ",")

        return get(.json(encoded: UserProfilesResponse.self, decoder: Profile.jsonDecoder), from: "ISteamUser/GetPlayerSummaries/v0002/")
            .adding(queryItems: ["key": apiKey.rawValue, "steamids": allSteamIDs])
    }
}

struct SteamClient {
    struct Failure: LocalizedError, Equatable {
        var failureReason: String?
    }

    var getFriendsList: (APIKey, SteamID) -> AnyPublisher<[SteamID], Failure>
    var getProfiles: (APIKey, [SteamID]) -> AnyPublisher<[Profile], Failure>
}

extension SteamClient {
    static var live: (URLSession) -> SteamClient = { session in
        SteamClient(
            getFriendsList: { apiKey, id in
                let request = SteamAPI(apiKey: apiKey).getFriendsList(forPlayerID: id)
                return session._perform(request)
                    .mapError { error in
                        let failureReason = (error.underlyingError as? LocalizedError)?.failureReason
                        return Failure(failureReason: failureReason)
                }
                .map(\.friends)
                .eraseToAnyPublisher()
        }, getProfiles: { apiKey, ids in
            let request = SteamAPI(apiKey: apiKey).getProfiles(forIDs: ids)
            return session._perform(request)
                .mapError { error in
                    let failureReason = (error.underlyingError as? LocalizedError)?.failureReason
                    return Failure(failureReason: failureReason)
            }
            .map(\.profiles)
            .eraseToAnyPublisher()
        })
    }
}

extension URLSession {
    func _perform<R: RequestConvertible>(_ request: R) -> Deferred<Future<R.Resource, RequestTransportError>> {
        Deferred {
            Future { promise in
                self.perform(request) { result in
                    switch result {
                    case .success((_, let resource)):
                        promise(.success(resource))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
