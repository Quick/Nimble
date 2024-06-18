#if !os(WASI)

import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class AsyncAwaitTest: XCTestCase { // swiftlint:disable:this type_body_length
    func testToPositiveMatches() async {
        @Sendable func someAsyncFunction() async throws -> Int {
            try await Task.sleep(nanoseconds: 1_000_000) // 1 millisecond
            return 1
        }

        await expect { try await someAsyncFunction() }.to(equal(1))
    }

    class Error: Swift.Error {}
    let errorToThrow = Error()

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testToEventuallyPositiveMatches() async {
        var value = 0
        deferToMainQueue { value = 1 }
        await expect { value }.toEventually(equal(1))

        deferToMainQueue { value = 0 }
        await expect { value }.toEventuallyNot(equal(1))
    }

    func testToEventuallyNegativeMatches() async {
        let value = 0
        await failsWithErrorMessage("expected to eventually not equal <0>, got <0>") {
            await expect { value }.toEventuallyNot(equal(0))
        }
        await failsWithErrorMessage("expected to eventually equal <1>, got <0>") {
            await expect { value }.toEventually(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            await expect { try self.doThrowError() }.toEventually(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            await expect { try self.doThrowError() }.toEventuallyNot(equal(0))
        }
    }

    func testToEventuallyWithAsyncExpressions() async {
        actor ExampleActor {
            private var count = 0

            func value() -> Int {
                count += 1
                return count
            }
        }

        let subject = ExampleActor()

        await expect { await subject.value() }.toEventually(equal(2))
    }

    func testToEventuallySyncCase() async {
        await expect(1).toEventually(equal(1), timeout: .seconds(300))
    }

    func testToEventuallyWaitingOnMainTask() async {
        class EncapsulatedValue {
            static var executed = false

            static func execute() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    Self.executed = true
                }
            }
        }

        EncapsulatedValue.execute()
        await expect(EncapsulatedValue.executed).toEventually(beTrue())
    }

    @MainActor
    func testToEventuallyOnMain() async {
        await expect(1).toEventually(equal(1), timeout: .seconds(300))
        await expect { try? await Task.sleep(nanoseconds: 10_000); return 1 }.toEventually(equal(1))
    }

    @MainActor
    func testToEventuallyMatcherIsAlwaysExecutedOnMainActor() async {
        // This prevents an issue where the main thread checker can get tripped up by us `stringify`ing
        // the expression in ``execute`` (Polling+AsyncAwait version). Which is annoying if the test
        // is otherwise correctly executing on the main thread.
        // Double-y so if your CI automatically reads backtraces (like what the main thread checker will output) as test crashes,
        // and fails your build.
        struct MySubject: CustomDebugStringConvertible, Equatable {
            var debugDescription: String {
                expect(Thread.isMainThread).to(beTrue())
                return "Test"
            }

            static func == (lhs: MySubject, rhs: MySubject) -> Bool {
                Thread.isMainThread
            }
        }

        await expect(MySubject()).toEventually(equal(MySubject()))
    }

    func testToEventuallyWithSyncExpectationAlwaysExecutesExpressionOnMainActor() async {
        await expect(Thread.isMainThread).toEventually(beTrue())
        await expect(Thread.isMainThread).toEventuallyNot(beFalse())
        await expect(Thread.isMainThread).toAlways(beTrue(), until: .seconds(1))
        await expect(Thread.isMainThread).toNever(beFalse(), until: .seconds(1))
    }

    func testToEventuallyWithAsyncExpectationDoesNotNecessarilyExecutesExpressionOnMainActor() async {
        // This prevents a "Class property 'isMainThread' is unavailable from asynchronous contexts; Work intended for the main actor should be marked with @MainActor; this is an error in Swift 6" warning.
        // However, the functionality actually works as you'd expect it to, you're just expected to tag things to use the main actor.
        @Sendable func isMainThread() -> Bool { Thread.isMainThread }

        await expecta(isMainThread()).toEventually(beFalse())
        await expecta(isMainThread()).toEventuallyNot(beTrue())
        await expecta(isMainThread()).toAlways(beFalse(), until: .seconds(1))
        await expecta(isMainThread()).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testToEventuallyWithAsyncExpectationDoesExecuteExpressionOnMainActorWhenTestRunsOnMainActor() async {
        // This prevents a "Class property 'isMainThread' is unavailable from asynchronous contexts; Work intended for the main actor should be marked with @MainActor; this is an error in Swift 6" warning.
        // However, the functionality actually works as you'd expect it to, you're just expected to tag things to use the main actor.
        @Sendable func isMainThread() -> Bool { Thread.isMainThread }

        await expecta(isMainThread()).toEventually(beTrue())
        await expecta(isMainThread()).toEventuallyNot(beFalse())
        await expecta(isMainThread()).toAlways(beTrue(), until: .seconds(1))
        await expecta(isMainThread()).toNever(beFalse(), until: .seconds(1))
    }

    func testToEventuallyWithCustomDefaultTimeout() async {
        PollingDefaults.timeout = .seconds(2)
        defer {
            PollingDefaults.timeout = .seconds(1)
        }

        var value = 0

        let sleepThenSetValueTo: (Int) -> Void = { newValue in
            Thread.sleep(forTimeInterval: 1.1)
            value = newValue
        }

        let task = Task {
            sleepThenSetValueTo(1)
        }
        await expect { value }.toEventually(equal(1))

        let secondTask = Task {
            sleepThenSetValueTo(0)
        }

        await expect { value }.toEventuallyNot(equal(1))

        _ = await task.value
        _ = await secondTask.result
    }

    func testWaitUntilWithCustomDefaultsTimeout() async {
        PollingDefaults.timeout = .seconds(3)
        defer {
            PollingDefaults.timeout = .seconds(1)
        }
        await waitUntil { done in
            Thread.sleep(forTimeInterval: 2.8)
            done()
        }
    }

    func testWaitUntilPositiveMatches() async {
        await waitUntil { done in
            done()
        }
        await waitUntil { done in
            deferToMainQueue {
                done()
            }
        }
    }

    func testWaitUntilTimesOutIfNotCalled() async {
        await failsWithErrorMessage("Waited more than 1.0 second") {
            await waitUntil(timeout: .seconds(1)) { _ in return }
        }
    }

    func testWaitUntilTimesOutWhenExceedingItsTime() async throws {
        actor WaitState {
            var waiting: Bool = true

            func stopWaiting() {
                waiting = false
            }
        }

        let waitState = WaitState()

        await failsWithErrorMessage("Waited more than 0.01 seconds") {
            await waitUntil(timeout: .milliseconds(10)) { done in
                Task {
                    _ = try? await Task.sleep(nanoseconds: 100_000_000)
                    done()
                    await waitState.stopWaiting()
                }
            }
        }

        // "clear" runloop to ensure this test doesn't poison other tests
        repeat {
            try await Task.sleep(nanoseconds: 200_000_000)
        } while(await waitState.waiting)
    }

    func testWaitUntilNegativeMatches() async {
        await failsWithErrorMessage("expected to equal <2>, got <1>") {
            await waitUntil { done in
                Thread.sleep(forTimeInterval: 0.1)
                expect(1).to(equal(2))
                done()
            }
        }
    }

    func testWaitUntilDetectsStalledMainThreadActivity() async {
        let msg = "-waitUntil() timed out but was unable to run the timeout handler because the main thread is unresponsive (0.5 seconds is allow after the wait times out). Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped run loop which may cause future failures in test run."
        await failsWithErrorMessage(msg) {
            await waitUntil(timeout: .seconds(1)) { done in
                Thread.sleep(forTimeInterval: 3.0)
                done()
            }
        }
    }

    func testWaitUntilErrorsIfDoneIsCalledMultipleTimes() async {
        await failsWithErrorMessage("waitUntil(..) expects its completion closure to be only called once") {
            await waitUntil { done in
                deferToMainQueue {
                    done()
                    done()
                }
            }
        }
    }

    func testWaitUntilDoesNotCompleteBeforeRunLoopIsWaiting() async {
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
        }
        timer.resume()

        for index in 0..<100 {
            if failed { break }
            await waitUntil(line: UInt(index)) { done in
                DispatchQueue(label: "Nimble.waitUntilTest.\(index)").async {
                    done()
                }
            }
        }

        timer.cancel()
    }

    final class ClassUnderTest {
        var deinitCalled: (() -> Void)?
        var count = 0
        deinit { deinitCalled?() }
    }

    func testSubjectUnderTestIsReleasedFromMemory() async {
        var subject: ClassUnderTest? = ClassUnderTest()

        if let sub = subject {
            await expect(sub.count).toEventually(equal(0), timeout: .milliseconds(100))
            await expect(sub.count).toEventuallyNot(equal(1), timeout: .milliseconds(100))
        }

        await waitUntil(timeout: .milliseconds(500)) { done in
            subject?.deinitCalled = {
                done()
            }

            deferToMainQueue { subject = nil }
        }
    }

    func testToNeverPositiveMatches() async {
        var value = 0
        deferToMainQueue { value = 1 }
        await expect { value }.toNever(beGreaterThan(1))

        deferToMainQueue { value = 0 }
        await expect { value }.neverTo(beGreaterThan(1))
    }

    func testToNeverNegativeMatches() async {
        var value = 0
        await failsWithErrorMessage("expected to never equal <0>, got <0>") {
            await expect { value }.toNever(equal(0))
        }
        await failsWithErrorMessage("expected to never equal <0>, got <0>") {
            await expect { value }.neverTo(equal(0))
        }
        await failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            await expect { value }.toNever(equal(1))
        }
        await failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            await expect { value }.neverTo(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            await expect { try self.doThrowError() }.toNever(equal(0))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            await expect { try self.doThrowError() }.neverTo(equal(0))
        }
    }

    func testToAlwaysPositiveMatches() async {
        var value = 1
        deferToMainQueue { value = 2 }
        await expect { value }.toAlways(beGreaterThan(0))

        deferToMainQueue { value = 2 }
        await expect { value }.alwaysTo(beGreaterThan(1))
    }

    func testToAlwaysNegativeMatches() async {
        var value = 1
        await failsWithErrorMessage("expected to always equal <0>, got <1>") {
            await expect { value }.toAlways(equal(0))
        }
        await failsWithErrorMessage("expected to always equal <0>, got <1>") {
            await expect { value }.alwaysTo(equal(0))
        }
        await failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            await expect { value }.toAlways(equal(1))
        }
        await failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            await expect { value }.alwaysTo(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            await expect { try self.doThrowError() }.toAlways(equal(0))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            await expect { try self.doThrowError() }.alwaysTo(equal(0))
        }
        await failsWithErrorMessage("expected to always equal <0>, got <nil> (use beNil() to match nils)") {
            await expect(nil).toAlways(equal(0))
        }
    }
}

#endif
