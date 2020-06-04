//
//  Remote.swift
//  SwiftPM Browser
//
//  Created by Alex Jackson on 29/05/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation

enum Loadable<T, E> {
    case notRequested
    case loading
    case loaded(T)
    case failed(E)

    var data: T? {
        if case .loaded(let data) = self { return data } else { return nil }
    }

    var error: E? {
        if case .failed(let error) = self { return error } else { return nil }
    }

    var isRequested: Bool {
        if case .notRequested = self { return false } else { return true }
    }

    var isLoading: Bool {
        if case .loading = self { return true } else { return false }
    }

    var isLoaded: Bool {
        if case .loaded = self { return true } else { return false }
    }

    var isFailed: Bool {
        if case .failed = self { return true } else { return false }
    }
}

extension Loadable: Equatable where T: Equatable, E: Equatable { }
