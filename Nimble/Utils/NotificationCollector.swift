//
//  NotificationCollector.swift
//  Nimble
//
//  Created by Brian Gerstle on 12/31/15.
//  Copyright © 2015 Jeff Hui. All rights reserved.
//

import Foundation

class NotificationCollector {

    private var observedNotifications: [NSNotification]
    private let notificationCenter: NSNotificationCenter
    private var token: AnyObject?

    required init(notificationCenter: NSNotificationCenter) {
        self.notificationCenter = notificationCenter
        self.observedNotifications = []
    }

    func startObserving() {
        self.token = self.notificationCenter.addObserverForName(nil, object: nil, queue: nil) { [weak self] n -> Void in
            self?.observedNotifications.append(n)
        }
    }

    deinit {
        if let token = self.token {
            self.notificationCenter.removeObserver(token)
        }
    }
}

public typealias CollectedNotificationsFunc = () throws -> [NSNotification]?

public func postedNotifications(notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter(),
                                block: () throws -> Void) -> CollectedNotificationsFunc {
    let collector = NotificationCollector(notificationCenter: notificationCenter)
    collector.startObserving()
    var once: Bool = false
    return {
        assert(NSThread.isMainThread(), "Only expecting closure to be evaluated on main thread.")
        if !once {
            once = true
            try block()
        }
        return collector.observedNotifications
    }
}
