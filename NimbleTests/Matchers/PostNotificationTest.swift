import XCTest
import Nimble

class PostNotificationTest: XCTestCase {
// MARK: - Passing

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
        let foo = NSObject()
        let bar = NSObject()
        let n1 = NSNotification(name: "Foo", object: foo)
        let n2 = NSNotification(name: "Bar", object: bar)
        expect {
            NSNotificationCenter.defaultCenter().postNotification(n1)
            NSNotificationCenter.defaultCenter().postNotification(n2)
            return nil
        }.to(postNotifications(equal([n1, n2])))
    }

// MARK: - Failing

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

// MARK: - Async

    func testPassesWhenExpectedNotificationEventuallyIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        expect {
            deferToMainQueue {
                NSNotificationCenter.defaultCenter().postNotification(testNotification)
            }
            return nil
        }.toEventually(postNotifications(equal([testNotification])))
    }
}
