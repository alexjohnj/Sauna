//
//  File.swift
//  
//
//  Created by Alex Jackson on 27/03/2021.
//

import Foundation
import UserNotifications

public struct Notifier {
    public var requestAuthorization: () -> Void
    public var postNotifications: ([UNNotificationRequest]) -> Void
    public var removeDeliveredNotifications: ([String]) -> Void

    public init(
        requestAuthorization: @escaping () -> Void,
        postNotifications: @escaping ([UNNotificationRequest]) -> Void,
        removeDeliveredNotifications: @escaping ([String]) -> Void
    ) {
        self.requestAuthorization = requestAuthorization
        self.postNotifications = postNotifications
        self.removeDeliveredNotifications = removeDeliveredNotifications
    }
}
