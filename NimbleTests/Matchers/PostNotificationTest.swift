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
        let pattern = try! "expected to equal <[NSConcreteNotification %addr% {name = Foo}]>, got <[]>"
                           .escapedRegularExpressionWithAddressToken()
        failsWithErrorMessage(pattern) {
            expect(expression: postedNotifications {
                // no notifications here!
            }).to(equal([testNotification]))
        }
    }

    func testFailsWhenNotificationWithWrongNameIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        let pattern = try! ("expected to equal <[NSConcreteNotification %addr% {name = Foo}]>,"
                           + " got <[NSConcreteNotification %addr% {name = Fooa}]>")
                           .escapedRegularExpressionWithAddressToken()
        failsWithErrorMessage(pattern) {
            expect(expression: postedNotifications {
                NSNotificationCenter.defaultCenter().postNotificationName(testNotification.name + "a", object: nil)
            }).to(equal([testNotification]))
        }
    }

    func testFailsWhenNotificationWithWrongObjectIsPosted() {
        let testNotification = NSNotification(name: "Foo", object: nil)
        let pattern = try! ("expected to equal <[NSConcreteNotification %addr% {name = Foo}]>,"
                           + " got <[NSConcreteNotification %addr% {name = Foo; object = <NSObject: %addr%>}]>")
                           .escapedRegularExpressionWithAddressToken()
        failsWithErrorMessage(pattern) {
            expect(expression: postedNotifications {
                NSNotificationCenter.defaultCenter().postNotificationName(testNotification.name, object: NSObject())
            }).to(equal([testNotification]))
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
