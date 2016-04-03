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

    var notificationCenter: NSNotificationCenter!

    #if _runtime(_ObjC)
    override func setUp() {
        _setUp()
        super.setUp()
    }
    #else
    func setUp() {
        _setUp()
    }
    #endif


    func _setUp() {
        notificationCenter = NSNotificationCenter()
    }

    func testPassesWhenNoNotificationsArePosted() {
        expect {
            // no notifications here!
            return nil
        }.to(postNotifications(beEmpty(), fromNotificationCenter: notificationCenter))
    }

    func testPassesWhenExpectedNotificationIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        expect {
            self.notificationCenter.postNotification(testNotification)
        }.to(postNotifications(equal([testNotification]), fromNotificationCenter: notificationCenter))
    }

    func testPassesWhenAllExpectedNotificationsArePosted() {
        let foo = NSNumber(int: 1)
        let bar = NSNumber(int: 2)
        let n1 = NSNotification(name: "Foo", object: foo)
        let n2 = NSNotification(name: "Bar", object: bar)
        expect {
            self.notificationCenter.postNotification(n1)
            self.notificationCenter.postNotification(n2)
            return nil
        }.to(postNotifications(equal([n1, n2]), fromNotificationCenter: notificationCenter))
    }

    func testFailsWhenNoNotificationsArePosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        failsWithErrorMessage("expected to equal <[\(testNotification)]>, got no notifications") {
            expect {
                // no notifications here!
                return nil
            }.to(postNotifications(equal([testNotification]), fromNotificationCenter: self.notificationCenter))
        }
    }

    func testFailsWhenNotificationWithWrongNameIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name + "a", object: nil)
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                self.notificationCenter.postNotification(n2)
                return nil
            }.to(postNotifications(equal([n1]), fromNotificationCenter: self.notificationCenter))
        }
    }

    func testFailsWhenNotificationWithWrongObjectIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name, object: NSObject())
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                self.notificationCenter.postNotification(n2)
                return nil
            }.to(postNotifications(equal([n1]), fromNotificationCenter: self.notificationCenter))
        }
    }

    func testPassesWhenExpectedNotificationEventuallyIsPosted() {
        #if _runtime(_ObjC)
            let testNotification = NSNotification(name: "Foo", object: nil)
            expect {
                deferToMainQueue {
                    self.notificationCenter.postNotification(testNotification)
                }
                return nil
            }.toEventually(postNotifications(equal([testNotification]), fromNotificationCenter: notificationCenter))
        #else
            print("\(#function) is missing because toEventually is not implement on this platform")
        #endif
    }
}