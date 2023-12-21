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
final class PollingRequireTest: XCTestCase {
    class Error: Swift.Error {}
    let errorToThrow = Error()

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testToEventuallyPositiveMatches() {
        var value = 0
        deferToMainQueue { value = 1 }
        expect {
            try require { value }.toEventually(equal(1))
        }.to(equal(1))

        deferToMainQueue { value = 0 }
        expect {
            try require { value }.toEventuallyNot(equal(1))
        }.to(equal(0))
    }

    func testToEventuallyNegativeMatches() {
        let value = 0
        failsWithErrorMessage("expected to eventually not equal <0>, got <0>") {
            try require { value }.toEventuallyNot(equal(0))
        }
        failsWithErrorMessage("expected to eventually equal <1>, got <0>") {
            try require { value }.toEventually(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.toEventually(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.toEventuallyNot(equal(0))
        }
    }

    func testPollUnwrapPositiveCase() {
        var value: Int? = nil
        deferToMainQueue {
            value = 1
        }
        expect {
            try pollUnwrap(value)
        }.to(equal(1))
    }

    func testPollUnwrapNegativeCase() {
        failsWithErrorMessage("expected to eventually not be nil, got <nil>") {
            do {
                try pollUnwrap(nil as Int?)
            } catch {}
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try pollUnwrap { try self.doThrowError() as Int? }
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try pollUnwrap { try self.doThrowError() as Int? }
        }
    }

    func testToEventuallySyncCase() throws {
        try require(1).toEventually(equal(1), timeout: .seconds(300))
    }

    func testToEventuallyWithCustomDefaultTimeout() throws {
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
        try require { value }.toEventually(equal(1))

        asyncOperation = { sleepThenSetValueTo(0) }

        DispatchQueue.global().async(execute: asyncOperation)
        try require { value }.toEventuallyNot(equal(1))
    }

    func testToEventuallyAllowsInBackgroundThread() {
#if !SWIFT_PACKAGE
        var executedAsyncBlock: Bool = false
        let asyncOperation: () -> Void = {
            do {
                try require {
                    expect(1).toEventually(equal(1))
                }.toNot(raiseException(named: "InvalidNimbleAPIUsage"))
            } catch {
                fail(error.localizedDescription)
                return
            }
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

    func testSubjectUnderTestIsReleasedFromMemory() throws {
        var subject: ClassUnderTest? = ClassUnderTest()

        if let sub = subject {
            try require(sub.count).toEventually(equal(0), timeout: .milliseconds(100))
            try require(sub.count).toEventuallyNot(equal(1), timeout: .milliseconds(100))
        }

        waitUntil(timeout: .milliseconds(500)) { done in
            subject?.deinitCalled = {
                done()
            }

            deferToMainQueue { subject = nil }
        }
    }

    func testToNeverPositiveMatches() throws {
        var value = 0
        deferToMainQueue { value = 1 }
        try require { value }.toNever(beGreaterThan(1))

        deferToMainQueue { value = 0 }
        try require { value }.neverTo(beGreaterThan(1))
    }

    func testToNeverNegativeMatches() {
        var value = 0
        failsWithErrorMessage("expected to never equal <0>, got <0>") {
            try require { value }.toNever(equal(0))
        }
        failsWithErrorMessage("expected to never equal <0>, got <0>") {
            try require { value }.neverTo(equal(0))
        }
        failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            try require { value }.toNever(equal(1))
        }
        failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value = 1 }
            try require { value }.neverTo(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.toNever(equal(0))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.neverTo(equal(0))
        }
    }

    func testToAlwaysPositiveMatches() throws {
        var value = 1
        deferToMainQueue { value = 2 }
        try require { value }.toAlways(beGreaterThan(0))

        deferToMainQueue { value = 2 }
        try require { value }.alwaysTo(beGreaterThan(1))
    }

    func testToAlwaysNegativeMatches() {
        var value = 1
        failsWithErrorMessage("expected to always equal <0>, got <1>") {
            try require { value }.toAlways(equal(0))
        }
        failsWithErrorMessage("expected to always equal <0>, got <1>") {
            try require { value }.alwaysTo(equal(0))
        }
        failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            try require { value }.toAlways(equal(1))
        }
        failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value = 0 }
            try require { value }.alwaysTo(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.toAlways(equal(0))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.alwaysTo(equal(0))
        }
    }
}

#endif // #if !os(WASI)

