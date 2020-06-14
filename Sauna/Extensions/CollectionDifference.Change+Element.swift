//
//  CollectionDifference.Change+Element.swift
//  Sauna
//
//  Created by Alex Jackson on 14/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

extension CollectionDifference.Change {
    var element: ChangeElement {
        switch self {
        case .insert(_, let element, _),
             .remove(_, let element, _):
            return element
        }
    }
}
