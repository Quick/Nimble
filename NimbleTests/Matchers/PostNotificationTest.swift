import XCTest
import Nimble

class PostNotificationTest: XCTestCase {
// MARK: - Passing

    func testPassesWhenNoNotificationsArePosted() {
        expect { () -> Void in
            // no notifications here!
        }.to(postNotifications(beEmpty()))
    }

    func testPassesWhenExpectedNotificationIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        expect {
            NSNotificationCenter.defaultCenter().postNotification(testNotification)
        }.to(postNotifications(equal([testNotification])))
    }

    func testPassesWhenAllExpectedNotificationsArePosted() {
        let foo = NSObject()
        let bar = NSObject()
        let n1 = NSNotification(name: "Foo", object: foo)
        let n2 = NSNotification(name: "Bar", object: bar)
        expect { () -> Void in
            NSNotificationCenter.defaultCenter().postNotification(n1)
            NSNotificationCenter.defaultCenter().postNotification(n2)
        }.to(postNotifications(equal([n1, n2])))
    }

// MARK: - Failing

    func testFailsWhenNoNotificationsArePosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        failsWithErrorMessage("expected to equal <[\(testNotification)]>, got no notifications") {
            expect { () -> Void in
                // no notifications here!
            }.to(postNotifications(equal([testNotification])))
        }
    }

    func testFailsWhenNotificationWithWrongNameIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name + "a", object: nil)
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                NSNotificationCenter.defaultCenter().postNotification(n2)
            }.to(postNotifications(equal([n1])))
        }
    }

    func testFailsWhenNotificationWithWrongObjectIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name, object: NSObject())
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                NSNotificationCenter.defaultCenter().postNotification(n2)
            }.to(postNotifications(equal([n1])))
        }
    }

// MARK: - Async

    func testPassesWhenExpectedNotificationEventuallyIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        expect {
            deferToMainQueue {
                NSNotificationCenter.defaultCenter().postNotification(testNotification)
            }
        }.toEventually(postNotifications(equal([testNotification])))
    }
}
