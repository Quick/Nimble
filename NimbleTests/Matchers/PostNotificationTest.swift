import XCTest
import Nimble

class PostNotificationTest: XCTestCase {
// MARK: - Passing

    func testPassesWhenNoNotificationsArePosted() {
        expect(expression: postedNotifications {
            // no notifications here!
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

    func testFailsWhenNoNotificationsArePosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        failsWithErrorMessage("expected to equal <[\(testNotification)]>, got <[]>") {
            expect(expression: postedNotifications {
                // no notifications here!
            }).to(equal([testNotification]))
        }
    }

    func testFailsWhenNotificationWithWrongNameIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name + "a", object: nil)
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect(expression: postedNotifications {
                NSNotificationCenter.defaultCenter().postNotification(n2)
            }).to(equal([n1]))
        }
    }

    func testFailsWhenNotificationWithWrongObjectIsPosted() {
        let n1 = NSNotification(name: "Foo", object: nil)
        let n2 = NSNotification(name: n1.name, object: NSObject())
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect(expression: postedNotifications {
                NSNotificationCenter.defaultCenter().postNotification(n2)
            }).to(equal([n1]))
        }
    }

// MARK: - Async

    func testPassesWhenExpectedNotificationEventuallyIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        expect(expression: postedNotifications {
            deferToMainQueue {
                NSNotificationCenter.defaultCenter().postNotification(testNotification)
            }
        }).toEventually(equal([testNotification]))
    }
}
