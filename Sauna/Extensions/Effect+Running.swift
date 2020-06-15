//
//  Effect+Completable.swift
//  Sauna
//
//  Created by Alex Jackson on 15/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import Foundation
import Combine
import ComposableArchitecture

extension Effect where Failure == Never {
    static func running(_ work: @escaping () -> Output) -> Self {
        Effect<Output, Never>.future { p in p(.success(work())) }
    }
}
