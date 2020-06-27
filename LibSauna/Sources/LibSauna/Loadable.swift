//
//  Remote.swift
//  SwiftPM Browser
//
//  Created by Alex Jackson on 29/05/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

public struct Loadable<T, E> {
    public enum State {
        case notRequested
        case idle(E?)
        case loading
    }

    public private(set) var state: State = .notRequested
    public private(set) var data: T?

    public mutating func startLoading() {
        state = .loading
    }

    public mutating func complete(_ data: T) {
        state = .idle(nil)
        self.data = data
    }

    public mutating func fail(with error: E) {
        state = .idle(error)
    }

    public init() { }
}

public extension Loadable {
    /// `true` if the data has at some point been requested.
    var isRequested: Bool {
        if case .notRequested = state { return false } else { return true }
    }

    /// `true` if data is being loaded or re-loaded.
    var isLoading: Bool {
        if case .loading = state { return true } else { return false }
    }

    /// `true` if there is data loaded.
    var isLoaded: Bool {
        data != nil
    }

    /// `true` if the last load failed.
    var isFailed: Bool {
        if case .idle(.some) = state { return true } else { return false }
    }

    /// The error associated with the last load attempt
    var error: E? {
        if case .idle(let error) = state { return error } else { return nil }
    }
}

extension Loadable where E: Error {
    public mutating func complete(_ result: Result<T, E>) {
        switch result {
        case .success(let data):
            complete(data)
        case .failure(let error):
            fail(with: error)
        }
    }
}

extension Loadable.State: Equatable where T: Equatable, E: Equatable { }
extension Loadable: Equatable where T: Equatable, E: Equatable { }
