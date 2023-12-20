#if !os(WASI)

import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class AsyncAwaitRequireTest: XCTestCase { // swiftlint:disable:this type_body_length
    func testToPositiveMatches() async throws {
        func someAsyncFunction() async throws -> Int {
            try await Task.sleep(nanoseconds: 1_000_000) // 1 millisecond
            return 1
        }

        try await require { try await someAsyncFunction() }.to(equal(1))
    }

    class Error: Swift.Error {}
    let errorToThrow = Error()

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testToEventuallyPositiveMatches() async throws {
        var value = 0
        deferToMainQueue { value = 1 }
        try await require { value }.toEventually(equal(1))

        deferToMainQueue { value = 0 }
        try await require { value }.toEventuallyNot(equal(1))
    }

    func testToEventuallyNegativeMatches() async {
        let value = 0
        await failsWithErrorMessage("expected to eventually not equal <0>, got <0>") {
            try await require { value }.toEventuallyNot(equal(0))
        }
        await failsWithErrorMessage("expected to eventually equal <1>, got <0>") {
            try await require { value }.toEventually(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await require { try self.doThrowError() }.toEventually(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await require { try self.doThrowError() }.toEventuallyNot(equal(0))
        }
    }

    func testPollUnwrapPositiveCase() async {
        func someAsyncFunction() async throws -> Int {
            try await Task.sleep(nanoseconds: 1_000_000) // 1 millisecond
            return 1
        }
        await expect {
            try await pollUnwrapa(await someAsyncFunction())
        }.to(equal(1))
    }

    func testPollUnwrapNegativeCase() async {
        await failsWithErrorMessage("expected to eventually not be nil, got nil") {
            try await pollUnwrap { nil as Int? }
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await pollUnwrap { try self.doThrowError() as Int? }
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await pollUnwrap { try self.doThrowError() as Int? }
        }
    }

    func testToEventuallyWithAsyncExpressions() async throws {
        actor ExampleActor {
            private var count = 0

            func value() -> Int {
                count += 1
                return count
            }
        }

        let subject = ExampleActor()

        try await require { await subject.value() }.toEventually(equal(2))
    }

    func testToEventuallySyncCase() async throws {
        try await require(1).toEventually(equal(1), timeout: .seconds(300))
    }

    func testToEventuallyWaitingOnMainTask() async throws {
        class EncapsulatedValue {
            static var executed = false

            static func execute() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    Self.executed = true
                }
            }
        }

        EncapsulatedValue.execute()
        try await require(EncapsulatedValue.executed).toEventually(beTrue())
    }

    @MainActor
    func testToEventuallyOnMain() async throws {
        try await require(1).toEventually(equal(1), timeout: .seconds(300))
        try await require { try? await Task.sleep(nanoseconds: 10_000); return 1 }.toEventually(equal(1))
    }

    @MainActor
    func testToEventuallyMatcherIsAlwaysExecutedOnMainActor() async throws {
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

        try await require(MySubject()).toEventually(equal(MySubject()))
    }

    func testToEventuallyWithSyncExpectationAlwaysExecutesExpressionOnMainActor() async throws {
        try await require(Thread.isMainThread).toEventually(beTrue())
        try await require(Thread.isMainThread).toEventuallyNot(beFalse())
        try await require(Thread.isMainThread).toAlways(beTrue(), until: .seconds(1))
        try await require(Thread.isMainThread).toNever(beFalse(), until: .seconds(1))
    }

    func testToEventuallyWithAsyncExpectationDoesNotNecessarilyExecutesExpressionOnMainActor() async throws {
        // This prevents a "Class property 'isMainThread' is unavailable from asynchronous contexts; Work intended for the main actor should be marked with @MainActor; this is an error in Swift 6" warning.
        // However, the functionality actually works as you'd expect it to, you're just expected to tag things to use the main actor.
        func isMainThread() -> Bool { Thread.isMainThread }

        try await requirea(isMainThread()).toEventually(beFalse())
        try await requirea(isMainThread()).toEventuallyNot(beTrue())
        try await requirea(isMainThread()).toAlways(beFalse(), until: .seconds(1))
        try await requirea(isMainThread()).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testToEventuallyWithAsyncExpectationDoesExecuteExpressionOnMainActorWhenTestRunsOnMainActor() async throws {
        // This prevents a "Class property 'isMainThread' is unavailable from asynchronous contexts; Work intended for the main actor should be marked with @MainActor; this is an error in Swift 6" warning.
        // However, the functionality actually works as you'd expect it to, you're just expected to tag things to use the main actor.
        func isMainThread() -> Bool { Thread.isMainThread }

        try await requirea(isMainThread()).toEventually(beTrue())
        try await requirea(isMainThread()).toEventuallyNot(beFalse())
        try await requirea(isMainThread()).toAlways(beTrue(), until: .seconds(1))
        try await requirea(isMainThread()).toNever(beFalse(), until: .seconds(1))
    }

    func testToEventuallyWithCustomDefaultTimeout() async throws {
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
        try await require { value }.toEventually(equal(1))

        let secondTask = Task {
            sleepThenSetValueTo(0)
        }

        try await require { value }.toEventuallyNot(equal(1))

        _ = await task.value
        _ = await secondTask.result
    }

    final class ClassUnderTest {
        var deinitCalled: (() -> Void)?
        var count = 0
        deinit { deinitCalled?() }
    }

    func testSubjectUnderTestIsReleasedFromMemory() async throws {
        var subject: ClassUnderTest? = ClassUnderTest()

        if let sub = subject {
            try await require(sub.count).toEventually(equal(0), timeout: .milliseconds(100))
            try await require(sub.count).toEventuallyNot(equal(1), timeout: .milliseconds(100))
        }

        await waitUntil(timeout: .milliseconds(500)) { done in
            subject?.deinitCalled = {
                done()
            }

            deferToMainQueue { subject = nil }
        }
    }

    func testToNeverPositiveMatches() async throws {
        var value = 0
        deferToMainQueue { value = 1 }
        try await require { value }.toNever(beGreaterThan(1))

        deferToMainQueue { value = 0 }
        try await require { value }.neverTo(beGreaterThan(1))
    }

    func testToNeverNegativeMatches() async {
        var value = 0
        await failsWithErrorMessage("expected to never equal <0>, got <0>") {
            try await require { value }.toNever(equal(0))
        }
        await failsWithErrorMessage("expected to never equal <0>, got <0>") {
            try await require { value }.neverTo(equal(0))
        }
        await failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            try await require { value }.toNever(equal(1))
        }
        await failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            try await require { value }.neverTo(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await require { try self.doThrowError() }.toNever(equal(0))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await require { try self.doThrowError() }.neverTo(equal(0))
        }
    }

    func testToAlwaysPositiveMatches() async throws {
        var value = 1
        deferToMainQueue { value = 2 }
        try await require { value }.toAlways(beGreaterThan(0))

        deferToMainQueue { value = 2 }
        try await require { value }.alwaysTo(beGreaterThan(1))
    }

    func testToAlwaysNegativeMatches() async {
        var value = 1
        await failsWithErrorMessage("expected to always equal <0>, got <1>") {
            try await require { value }.toAlways(equal(0))
        }
        await failsWithErrorMessage("expected to always equal <0>, got <1>") {
            try await require { value }.alwaysTo(equal(0))
        }
        await failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            try await require { value }.toAlways(equal(1))
        }
        await failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            try await require { value }.alwaysTo(equal(1))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await require { try self.doThrowError() }.toAlways(equal(0))
        }
        await failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try await require { try self.doThrowError() }.alwaysTo(equal(0))
        }
    }
}

#endif

