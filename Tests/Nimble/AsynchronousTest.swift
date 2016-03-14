import Foundation
import XCTest
import Nimble

// These tests require the ObjC runtimes do not currently have the GCD and run loop facilities
// required for working with Nimble's async matchers
#if _runtime(_ObjC)

class AsyncTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testToEventuallyPositiveMatches", testToEventuallyPositiveMatches),
            ("testToEventuallyNegativeMatches", testToEventuallyNegativeMatches),
            ("testWaitUntilPositiveMatches", testWaitUntilPositiveMatches),
            ("testToEventuallyWithCustomDefaultTimeout", testToEventuallyWithCustomDefaultTimeout),
            ("testWaitUntilTimesOutIfNotCalled", testWaitUntilTimesOutIfNotCalled),
            ("testWaitUntilTimesOutWhenExceedingItsTime", testWaitUntilTimesOutWhenExceedingItsTime),
            ("testWaitUntilNegativeMatches", testWaitUntilNegativeMatches),
            ("testWaitUntilDetectsStalledMainThreadActivity", testWaitUntilDetectsStalledMainThreadActivity),
            ("testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed", testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed),
            ("testWaitUntilErrorsIfDoneIsCalledMultipleTimes", testWaitUntilErrorsIfDoneIsCalledMultipleTimes),
            ("testWaitUntilMustBeInMainThread", testWaitUntilMustBeInMainThread),
            ("testToEventuallyMustBeInMainThread", testToEventuallyMustBeInMainThread),
        ]
    }

    let errorToThrow = NSError(domain: NSInternalInconsistencyException, code: 42, userInfo: nil)

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testToEventuallyPositiveMatches() {
        var value = 0
        deferToMainQueue { value = 1 }
        expect { value }.toEventually(equal(1))

        deferToMainQueue { value = 0 }
        expect { value }.toEventuallyNot(equal(1))
    }

    func testToEventuallyNegativeMatches() {
        let value = 0
        failsWithErrorMessage("expected to eventually not equal <0>, got <0>") {
            expect { value }.toEventuallyNot(equal(0))
        }
        failsWithErrorMessage("expected to eventually equal <1>, got <0>") {
            expect { value }.toEventually(equal(1))
        }
        failsWithErrorMessage("expected to eventually equal <1>, got an unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventually(equal(1))
        }
        failsWithErrorMessage("expected to eventually not equal <0>, got an unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventuallyNot(equal(0))
        }
    }

    func testToEventuallyWithCustomDefaultTimeout() {
        AsyncDefaults.Timeout = 2
        defer {
            AsyncDefaults.Timeout = 1
        }

        var value = 0

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            NSThread.sleepForTimeInterval(1.1)
            value = 1
        }
        expect { value }.toEventually(equal(1))

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            NSThread.sleepForTimeInterval(1.1)
            value = 0
        }
        expect { value }.toEventuallyNot(equal(1))
    }

    func testWaitUntilPositiveMatches() {
        waitUntil { done in
            done()
        }
        waitUntil { done in
            deferToMainQueue {
                done()
            }
        }
    }

    func testWaitUntilTimesOutIfNotCalled() {
        failsWithErrorMessage("Waited more than 1.0 second") {
            waitUntil(timeout: 1) { done in return }
        }
    }

    func testWaitUntilTimesOutWhenExceedingItsTime() {
        var waiting = true
        failsWithErrorMessage("Waited more than 0.01 seconds") {
            waitUntil(timeout: 0.01) { done in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    NSThread.sleepForTimeInterval(0.1)
                    done()
                    waiting = false
                }
            }
        }

        // "clear" runloop to ensure this test doesn't poison other tests
        repeat {
            NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(0.2))
        } while(waiting)
    }

    func testWaitUntilNegativeMatches() {
        failsWithErrorMessage("expected to equal <2>, got <1>") {
            waitUntil { done in
                NSThread.sleepForTimeInterval(0.1)
                expect(1).to(equal(2))
                done()
            }
        }
    }

    func testWaitUntilDetectsStalledMainThreadActivity() {
        let msg = "-waitUntil() timed out but was unable to run the timeout handler because the main thread is unresponsive (0.5 seconds is allow after the wait times out). Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped run loop which may cause future failures in test run."
        failsWithErrorMessage(msg) {
            waitUntil(timeout: 1) { done in
                NSThread.sleepForTimeInterval(5.0)
                done()
            }
        }
    }

    func testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed() {
        // Currently we are unable to catch Objective-C exceptions when built by the Swift Package Manager
#if !SWIFT_PACKAGE
        let referenceLine = __LINE__ + 9
        var msg = "Unexpected exception raised: Nested async expectations are not allowed "
        msg += "to avoid creating flaky tests."
        msg += "\n\n"
        msg += "The call to\n\t"
        msg += "expect(...).toEventually(...) at \(__FILE__):\(referenceLine + 7)\n"
        msg += "triggered this exception because\n\t"
        msg += "waitUntil(...) at \(__FILE__):\(referenceLine + 1)\n"
        msg += "is currently managing the main run loop."
        failsWithErrorMessage(msg) { // reference line
            waitUntil(timeout: 2.0) { done in
                var protected: Int = 0
                dispatch_async(dispatch_get_main_queue()) {
                    protected = 1
                }

                expect(protected).toEventually(equal(1))
                done()
            }
        }
#endif
    }

    func testWaitUntilErrorsIfDoneIsCalledMultipleTimes() {
#if !SWIFT_PACKAGE
        waitUntil { done in
            deferToMainQueue {
                done()
                expect {
                    done()
                }.to(raiseException(named: "InvalidNimbleAPIUsage"))
            }
        }
#endif
    }

    func testWaitUntilMustBeInMainThread() {
#if !SWIFT_PACKAGE
        var executedAsyncBlock: Bool = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            expect {
                waitUntil { done in done() }
            }.to(raiseException(named: "InvalidNimbleAPIUsage"))
            executedAsyncBlock = true
        }
        expect(executedAsyncBlock).toEventually(beTruthy())
#endif
    }

    func testToEventuallyMustBeInMainThread() {
#if !SWIFT_PACKAGE
        var executedAsyncBlock: Bool = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            expect {
                expect(1).toEventually(equal(2))
            }.to(raiseException(named: "InvalidNimbleAPIUsage"))
            executedAsyncBlock = true
        }
        expect(executedAsyncBlock).toEventually(beTruthy())
#endif
    }
}
#endif

