#if !os(WASI)

import XCTest
import Nimble
import Foundation
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class PostNotificationTest: XCTestCase {
    let notificationCenter = NotificationCenter()

    func testPassesWhenNoNotificationsArePosted() {
        expect {
            // no notifications here!
        }.to(postNotifications(beEmpty()))
    }

    func testPassesWhenExpectedNotificationIsPosted() {
        let testNotification = Notification(name: Notification.Name("Foo"), object: nil)
        expect {
            self.notificationCenter.post(Notification(name: Notification.Name("Foo"), object: nil))
        }.to(postNotifications(equal([testNotification]), from: notificationCenter))
    }

    func testPassesWhenAllExpectedNotificationsArePosted() {
        let foo = 1 as NSNumber
        let bar = 2 as NSNumber
        let n1 = Notification(name: Notification.Name("Foo"), object: foo)
        let n2 = Notification(name: Notification.Name("Bar"), object: bar)
        expect {
            self.notificationCenter.post(Notification(name: Notification.Name("Foo"), object: foo))
            self.notificationCenter.post(Notification(name: Notification.Name("Bar"), object: bar))
        }.to(postNotifications(equal([n1, n2]), from: notificationCenter))
    }

    func testFailsWhenNoNotificationsArePosted() {
        let testNotification = Notification(name: Notification.Name("Foo"), object: nil)
        failsWithErrorMessage("expected to equal <[\(testNotification)]>, got no notifications") {
            expect {
                // no notifications here!
            }.to(postNotifications(equal([testNotification]), from: self.notificationCenter))
        }
    }

    func testFailsWhenNotificationWithWrongNameIsPosted() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        let n2 = Notification(name: Notification.Name(n1.name.rawValue + "a"), object: nil)
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                self.notificationCenter.post(Notification(name: Notification.Name("Fooa"), object: nil))
            }.to(postNotifications(equal([n1]), from: self.notificationCenter))
        }
    }

    func testFailsWhenNotificationWithWrongObjectIsPosted() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        let object = NSObject()
        let n2 = Notification(name: n1.name, object: object)
        failsWithErrorMessage("expected to equal <[\(n1)]>, got <[\(n2)]>") {
            expect {
                self.notificationCenter.post(Notification(name: Notification.Name("Foo"), object: object))
            }.to(postNotifications(equal([n1]), from: self.notificationCenter))
        }
    }

    func testPassesWhenExpectedNotificationEventuallyIsPosted() {
        let testNotification = Notification(name: Notification.Name("Foo"), object: nil)
        expect {
            deferToMainQueue {
                self.notificationCenter.post(Notification(name: Notification.Name("Foo"), object: nil))
            }
        }.toEventually(postNotifications(equal([testNotification]), from: notificationCenter))
    }

    func testFailsWhenNotificationIsPostedUnexpectedly() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        failsWithErrorMessage("expected to not equal <[\(n1)]>, got <[\(n1)]>") {
            expect {
                self.notificationCenter.post(Notification(name: Notification.Name("Foo"), object: nil))
            }.toNot(postNotifications(equal([n1]), from: self.notificationCenter))
        }
    }

    func testPassesWhenNotificationIsNotPosted() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        expect {
            self.notificationCenter.post(Notification(name: Notification.Name("Fooa"), object: nil))
        }.toNever(postNotifications(equal([n1]), from: self.notificationCenter))
    }

    func testPassesWhenNotificationIsPostedFromADifferentThread() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        expect {
            OperationQueue().addOperations([
                BlockOperation {
                    let backgroundThreadObject = BackgroundThreadObject()
                    let n2 = Notification(name: Notification.Name("Bar"), object: backgroundThreadObject)
                    self.notificationCenter.post(n2)
                },
            ], waitUntilFinished: true)
            self.notificationCenter.post(Notification(name: Notification.Name("Foo"), object: nil))
        }.to(postNotifications(contain([n1]), from: notificationCenter))
    }

    func testPassesWhenNotificationIsPostedFromADifferentThreadAndToNotCalled() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        expect {
            OperationQueue().addOperations([
                BlockOperation {
                    let backgroundThreadObject = BackgroundThreadObject()
                    let n2 = Notification(name: Notification.Name("Fooa"), object: backgroundThreadObject)
                    self.notificationCenter.post(n2)
                },
            ], waitUntilFinished: true)
        }.toNot(postNotifications(equal([n1]), from: notificationCenter))
    }

    #if os(macOS)
    func testPassesWhenAllExpectedNotificationsarePostedInDistributedNotificationCenter() {
        let center = DistributedNotificationCenter()
        let n1 = Notification(name: Notification.Name("Foo"), object: "1")
        let n2 = Notification(name: Notification.Name("Bar"), object: "2")
        expect {
            center.post(Notification(name: Notification.Name("Foo"), object: "1"))
            center.post(Notification(name: Notification.Name("Bar"), object: "2"))
        }.toEventually(postDistributedNotifications(equal([n1, n2]), from: center, names: [n1.name, n2.name]))
    }
    #endif
}

#endif // #if !os(WASI)
