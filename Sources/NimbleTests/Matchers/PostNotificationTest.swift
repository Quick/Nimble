import XCTest
import Nimble
import Foundation

class PostNotificationTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testPassesWhenNoNotificationsArePosted", testPassesWhenNoNotificationsArePosted),
            ("testPassesWhenExpectedNotificationIsPosted", testPassesWhenExpectedNotificationIsPosted),
            ("testPassesWhenAllExpectedNotificationsArePosted", testPassesWhenAllExpectedNotificationsArePosted),
            ("testFailsWhenNoNotificationsArePosted", testFailsWhenNoNotificationsArePosted),
            ("testFailsWhenNotificationWithWrongNameIsPosted", testFailsWhenNotificationWithWrongNameIsPosted),
            ("testFailsWhenNotificationWithWrongObjectIsPosted", testFailsWhenNotificationWithWrongObjectIsPosted),
            ("testPassesWhenExpectedNotificationEventuallyIsPosted", testPassesWhenExpectedNotificationEventuallyIsPosted),
        ]
    }

    func testPassesWhenNoNotificationsArePosted() {
        expect {
            // no notifications here!
            return nil
        }.to(postNotifications(beEmpty()))
    }

    func testPassesWhenExpectedNotificationIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        expect {
            NSNotificationCenter.defaultCenter().postNotification(testNotification)
        }.to(postNotifications(equal([testNotification])))
    }

    func testPassesWhenAllExpectedNotificationsArePosted() {
        let foo = NSNumber(int: 1)
        let bar = NSNumber(int: 2)
        let n1 = NSNotification(name: "Foo", object: foo)
        let n2 = NSNotification(name: "Bar", object: bar)
        expect {
            NSNotificationCenter.defaultCenter().postNotification(n1)
            NSNotificationCenter.defaultCenter().postNotification(n2)
            return nil
        }.to(postNotifications(equal([n1, n2])))
    }

    func testFailsWhenNoNotificationsArePosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        failsWithErrorMessage("expected to equal <[\(testNotification)]>, got no notifications") {
            expect {
                // no notifications here!
                return nil
            }.to(postNotifications(equal([testNotification])))
        }
    }

    func testFailsWhenNotificationWithWrongNameIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name + "a", object: nil)
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                NSNotificationCenter.defaultCenter().postNotification(n2)
                return nil
            }.to(postNotifications(equal([n1])))
        }
    }

    func testFailsWhenNotificationWithWrongObjectIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name, object: NSObject())
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                NSNotificationCenter.defaultCenter().postNotification(n2)
                return nil
            }.to(postNotifications(equal([n1])))
        }
    }

    func testPassesWhenExpectedNotificationEventuallyIsPosted() {
        #if _runtime(_ObjC)
            let testNotification = NSNotification(name: "Foo", object: nil)
            expect {
                deferToMainQueue {
                    NSNotificationCenter.defaultCenter().postNotification(testNotification)
                }
                return nil
                }.toEventually(postNotifications(equal([testNotification])))
        #else
            print("\(__FUNCTION__) is missing because toEventually is not implement on this platform")
        #endif
    }
}