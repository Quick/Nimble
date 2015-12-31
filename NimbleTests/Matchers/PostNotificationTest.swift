//
//  PostNotificationTest.swift
//  Nimble
//
//  Created by Brian Gerstle on 12/28/15.
//  Copyright © 2015 Jeff Hui. All rights reserved.
//

import XCTest
import Nimble

class PostNotificationTest: XCTestCase {
// MARK: - Passing

    func testPassesWhenNoNotificationsArePosted() {
        expect(expression: postedNotifications {
        }).to(beEmpty())
    }

    func testPassesWhenExpectedNotificationIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        expect(expression: postedNotifications {
            NSNotificationCenter.defaultCenter().postNotification(testNotification)
        }).to(equal([testNotification]))
    }

    func testPassesWhenAllExpectedNotificationsArePosted() {
        let foo = NSObject()
        let bar = NSObject()
        let n1 = NSNotification(name: "Foo", object: foo)
        let n2 = NSNotification(name: "Bar", object: bar)
        expect(expression: postedNotifications {
            NSNotificationCenter.defaultCenter().postNotification(n1)
            NSNotificationCenter.defaultCenter().postNotification(n2)
        }).to(equal([n1, n2]))
    }

// MARK: - Failing



}
