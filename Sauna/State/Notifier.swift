//
//  Notifier.swift
//  Sauna
//
//  Created by Alex Jackson on 13/06/2020.
//  Copyright © 2020 Alex Jackson. All rights reserved.
//

import UserNotifications

struct Notifier {
    var requestAuthorization: () -> Void
    var postNotifications: ([UNNotificationRequest]) -> Void
    var removeDeliveredNotifications: ([String]) -> Void
}

extension Notifier {
    static let user: (UNUserNotificationCenter) -> Notifier = { center in
        Notifier(
            requestAuthorization: { center.requestAuthorization(options: .alert, completionHandler: { _, _ in })},
            postNotifications: { notifications in
                for notification in notifications {
                    center.add(notification, withCompletionHandler: nil)
                }
        },
            removeDeliveredNotifications: center.removeDeliveredNotifications(withIdentifiers:)
        )
    }
}
