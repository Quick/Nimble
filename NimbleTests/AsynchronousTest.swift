import XCTest
import Nimble

class AsyncTest: XCTestCase {
    func testAsyncTestingViaEventually() {
        var value = 0
        deferToMainQueue { value = 1 }
        expect { value }.toEventually(equal(1))

        deferToMainQueue { value = 0 }
        expect { value }.toEventuallyNot(equal(1))

        failsWithErrorMessage("expected to eventually not equal <0>, got <0>") {
            expect { value }.toEventuallyNot(equal(0))
        }
        failsWithErrorMessage("expected to eventually equal <1>, got <0>") {
            expect { value }.toEventually(equal(1))
        }
    }

    func testAsyncTestingViaWaitUntil() {
        waitUntil { done in
            done()
        }
        waitUntil { done in
            deferToMainQueue {
                done()
            }
        }
        failsWithErrorMessage("Waited more than 1.0 second") {
            waitUntil(timeout: 1) { done in return }
        }
        failsWithErrorMessage("Waited more than 0.01 seconds") {
            waitUntil(timeout: 0.01) { done in
                NSThread.sleepForTimeInterval(0.1)
                done()
            }
        }

        failsWithErrorMessage("expected to equal <2>, got <1>") {
            waitUntil { done in
                NSThread.sleepForTimeInterval(0.1)
                expect(1).to(equal(2))
                done()
            }
        }
    }

    func testWaitUntilDetectsStalledMainThreadActivity() {
        dispatch_async(dispatch_get_main_queue()) {
            NSThread.sleepForTimeInterval(2.0)
        }

        failsWithErrorMessage("Stall on main thread - too much enqueued on main run loop before waitUntil executes.") {
            waitUntil { done in
                done()
            }
        }
    }
    
    func testToEventuallyMatch_CustomFailureMessage() {
        failsWithErrorMessage(
            "These aren't eventually equal!\n" +
            "expected to eventually equal <1>, got <0>") {
            expect { 0 }.toEventually(equal(1), description: "These aren't eventually equal!")
        }
    }
    
    func testToEventuallyNotMatch_CustomFailureMessage() {
        failsWithErrorMessage(
            "These are eventually equal!\n" +
            "expected to eventually not equal <1>, got <1>") {
                expect { 1 }.toEventuallyNot(equal(1), description: "These are eventually equal!")
        }
    }
    
    func testToNotEventuallyMatch_CustomFailureMessage() {
        failsWithErrorMessage(
            "These are eventually equal!\n" +
            "expected to eventually not equal <1>, got <1>") {
                expect { 1 }.toEventuallyNot(equal(1), description: "These are eventually equal!")
        }
    }
}
