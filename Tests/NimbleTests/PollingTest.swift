#if !os(WASI)

import Dispatch
#if canImport(CoreFoundation)
import CoreFoundation
#endif
import Foundation
import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

// swiftlint:disable:next type_body_length
final class PollingTest: XCTestCase {
    struct Error: Swift.Error, Sendable {}
    let errorToThrow = Error()

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
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventually(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventuallyNot(equal(0))
        }
    }

    func testToEventuallySyncCase() {
        expect(1).toEventually(equal(1), timeout: .seconds(300))
    }

    func testToEventuallyWithCustomDefaultTimeout() {
        PollingDefaults.timeout = .seconds(2)
        defer {
            PollingDefaults.timeout = .seconds(1)
        }

        var value = 0

        let sleepThenSetValueTo: (Int) -> Void = { newValue in
            Thread.sleep(forTimeInterval: 1.1)
            value = newValue
        }

        var asyncOperation: () -> Void = { sleepThenSetValueTo(1) }

        DispatchQueue.global().async(execute: asyncOperation)
        expect { value }.toEventually(equal(1))

        asyncOperation = { sleepThenSetValueTo(0) }

        DispatchQueue.global().async(execute: asyncOperation)
        expect { value }.toEventuallyNot(equal(1))
    }

    func testWaitUntilWithCustomDefaultsTimeout() {
        PollingDefaults.timeout = .seconds(3)
        defer {
            PollingDefaults.timeout = .seconds(1)
        }
        waitUntil { done in
            Thread.sleep(forTimeInterval: 2.8)
            done()
        }
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
            waitUntil(timeout: .seconds(1)) { _ in return }
        }
    }

    func testWaitUntilTimesOutWhenExceedingItsTime() {
        var waiting = true
        failsWithErrorMessage("Waited more than 0.01 seconds") {
            waitUntil(timeout: .milliseconds(10)) { done in
                let asyncOperation: () -> Void = {
                    Thread.sleep(forTimeInterval: 0.1)
                    done()
                    waiting = false
                }
                DispatchQueue.global().async(execute: asyncOperation)
            }
        }

        // "clear" runloop to ensure this test doesn't poison other tests
        repeat {
            RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        } while(waiting)
    }

    func testWaitUntilNegativeMatches() {
        failsWithErrorMessage("expected to equal <2>, got <1>") {
            waitUntil { done in
                Thread.sleep(forTimeInterval: 0.1)
                expect(1).to(equal(2))
                done()
            }
        }
    }

    func testWaitUntilDetectsStalledMainThreadActivity() {
        let msg = "-waitUntil() timed out but was unable to run the timeout handler because the main thread is unresponsive (0.5 seconds is allow after the wait times out). Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped run loop which may cause future failures in test run."
        failsWithErrorMessage(msg) {
            waitUntil(timeout: .seconds(1)) { done in
                Thread.sleep(forTimeInterval: 3.0)
                done()
            }
        }
    }

    func testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed() {
        // Currently we are unable to catch Objective-C exceptions when built by the Swift Package Manager
#if !SWIFT_PACKAGE
        let referenceLine = #line + 10
        let msg = """
            Unexpected exception raised: Nested async expectations are not allowed to avoid creating flaky tests.

            The call to
            \texpect(...).toEventually(...) at \(#file):\(referenceLine + 7)
            triggered this exception because
            \twaitUntil(...) at \(#file):\(referenceLine + 1)
            is currently managing the main run loop.
            """
        failsWithErrorMessage(msg) { // reference line
            waitUntil(timeout: .seconds(2)) { done in
                var protected: Int = 0
                DispatchQueue.main.async {
                    protected = 1
                }

                expect(protected).toEventually(equal(1))
                done()
            }
        }
#endif
    }

    func testWaitUntilErrorsIfDoneIsCalledMultipleTimes() {
        failsWithErrorMessage("waitUntil(..) expects its completion closure to be only called once") {
            waitUntil { done in
                deferToMainQueue {
                    done()
                    done()
                }
            }
        }
    }

    func testWaitUntilDoesNotCompleteBeforeRunLoopIsWaiting() {
#if canImport(Darwin)
        // This verifies the fix for a race condition in which `done()` is
        // called asynchronously on a background thread after the main thread checks
        // for completion, but prior to `RunLoop.current.run(mode:before:)` being called.
        // This race condition resulted in the RunLoop locking up.
        var failed = false

        let timeoutQueue = DispatchQueue(label: "Nimble.waitUntilTest.timeout", qos: .background)
        let timer = DispatchSource.makeTimerSource(flags: .strict, queue: timeoutQueue)
        timer.schedule(
            deadline: DispatchTime.now() + 5,
            repeating: .never,
            leeway: .milliseconds(1)
        )
        timer.setEventHandler {
            failed = true
            fail("Timed out: Main RunLoop stalled.")
            CFRunLoopStop(CFRunLoopGetMain())
        }
        timer.resume()

        for index in 0..<100 {
            if failed { break }
            waitUntil(line: UInt(index)) { done in
                DispatchQueue(label: "Nimble.waitUntilTest.\(index)").async {
                    done()
                }
            }
        }

        timer.cancel()
#endif // canImport(Darwin)
    }

    func testWaitUntilAllowsInBackgroundThread() {
#if !SWIFT_PACKAGE
        var executedAsyncBlock: Bool = false
        let asyncOperation: () -> Void = {
            expect {
                waitUntil { done in done() }
            }.toNot(raiseException(named: "InvalidNimbleAPIUsage"))
            executedAsyncBlock = true
        }
        DispatchQueue.global().async(execute: asyncOperation)
        expect(executedAsyncBlock).toEventually(beTruthy())
#endif
    }

    func testToEventuallyAllowsInBackgroundThread() {
#if !SWIFT_PACKAGE
        var executedAsyncBlock: Bool = false
        let asyncOperation: () -> Void = {
            expect {
                expect(1).toEventually(equal(1))
            }.toNot(raiseException(named: "InvalidNimbleAPIUsage"))
            executedAsyncBlock = true
        }
        DispatchQueue.global().async(execute: asyncOperation)
        expect(executedAsyncBlock).toEventually(beTruthy())
#endif
    }

    final class ClassUnderTest {
        var deinitCalled: (() -> Void)?
        var count = 0
        deinit { deinitCalled?() }
    }

    func testSubjectUnderTestIsReleasedFromMemory() {
        var subject: ClassUnderTest? = ClassUnderTest()

        if let sub = subject {
            expect(sub.count).toEventually(equal(0), timeout: .milliseconds(100))
            expect(sub.count).toEventuallyNot(equal(1), timeout: .milliseconds(100))
        }

        waitUntil(timeout: .milliseconds(500)) { done in
            subject?.deinitCalled = {
                done()
            }

            deferToMainQueue { subject = nil }
        }
    }

    func testToNeverPositiveMatches() {
        var value = 0
        deferToMainQueue { value = 1 }
        expect { value }.toNever(beGreaterThan(1))

        deferToMainQueue { value = 0 }
        expect { value }.neverTo(beGreaterThan(1))
    }

    func testToNeverNegativeMatches() {
        var value = 0
        failsWithErrorMessage("expected to never equal <0>, got <0>") {
            expect { value }.toNever(equal(0))
        }
        failsWithErrorMessage("expected to never equal <0>, got <0>") {
            expect { value }.neverTo(equal(0))
        }
        failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            expect { value }.toNever(equal(1))
        }
        failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            expect { value }.neverTo(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toNever(equal(0))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.neverTo(equal(0))
        }
        failsWithErrorMessage("expected to never equal <0>, got <0>") {
            expect(0).toNever(equal(0))
        }
    }

    func testToAlwaysPositiveMatches() {
        var value = 1
        deferToMainQueue { value = 2 }
        expect { value }.toAlways(beGreaterThan(0))

        deferToMainQueue { value = 2 }
        expect { value }.alwaysTo(beGreaterThan(1))
    }

    func testToAlwaysNegativeMatches() {
        var value = 1
        failsWithErrorMessage("expected to always equal <0>, got <1>") {
            expect { value }.toAlways(equal(0))
        }
        failsWithErrorMessage("expected to always equal <0>, got <1>") {
            expect { value }.alwaysTo(equal(0))
        }
        failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            expect { value }.toAlways(equal(1))
        }
        failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            expect { value }.alwaysTo(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toAlways(equal(0))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.alwaysTo(equal(0))
        }
        failsWithErrorMessage("expected to always equal <0>, got <nil> (use beNil() to match nils)") {
            expect(nil).toAlways(equal(0))
        }
    }
}

#endif // #if !os(WASI)
