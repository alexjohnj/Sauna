//
//  Either.swift
//  Steam Snooper
//
//  Created by Alex Jackson on 05/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//
enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

extension Either: Equatable where Left: Equatable, Right: Equatable { }
