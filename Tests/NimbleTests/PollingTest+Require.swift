#if !os(WASI)

import Dispatch
#if canImport(CoreFoundation)
import CoreFoundation
#endif
import Foundation
import XCTest
@testable import Nimble
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
        let value = LockedContainer<Int>(0)
        deferToMainQueue { value.set(1) }
        expect {
            try require { value.value }.toEventually(equal(1))
        }.to(equal(1))

        deferToMainQueue { value.set(0) }
        expect {
            try require { value.value }.toEventuallyNot(equal(1))
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
        let value = LockedContainer<Int?>(nil)
        deferToMainQueue { value.set(1) }
        expect {
            try pollUnwrap(value.value)
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

        let value = LockedContainer<Int>(0)

        let sleepThenSetValueTo: (Int) -> Void = { newValue in
            Thread.sleep(forTimeInterval: 1.1)
            value.set(newValue)
        }

        var asyncOperation: () -> Void = { sleepThenSetValueTo(1) }

        DispatchQueue.global().async(execute: asyncOperation)
        try require { value.value }.toEventually(equal(1))

        asyncOperation = { sleepThenSetValueTo(0) }

        DispatchQueue.global().async(execute: asyncOperation)
        try require { value.value }.toEventuallyNot(equal(1))
    }

    func testToEventuallyAllowsInBackgroundThread() {
#if !SWIFT_PACKAGE
        let executedAsyncBlock = LockedContainer(false)
        let asyncOperation: @Sendable () -> Void = {
            do {
                try require {
                    expect(1).toEventually(equal(1))
                }.toNot(raiseException(named: "InvalidNimbleAPIUsage"))
            } catch {
                fail(error.localizedDescription)
                return
            }
            executedAsyncBlock.set(true)
        }
        DispatchQueue.global().async(execute: asyncOperation)
        expect(executedAsyncBlock.value).toEventually(beTruthy())
#endif
    }

    final class ClassUnderTest: Sendable {
        let deinitCalled = LockedContainer<(@Sendable () -> Void)?>(nil)
        let count = LockedContainer(0)
        deinit { deinitCalled.value?() }
    }

    func testSubjectUnderTestIsReleasedFromMemory() throws {
        let subject = LockedContainer<ClassUnderTest?>(ClassUnderTest())

        if let sub = subject.value {
            try require(sub.count.value).toEventually(equal(0), timeout: .milliseconds(100))
            try require(sub.count.value).toEventuallyNot(equal(1), timeout: .milliseconds(100))
        }

        waitUntil(timeout: .milliseconds(500)) { done in
            subject.value?.deinitCalled.set({
                done()
            })

            deferToMainQueue { subject.set(nil) }
        }
    }

    func testToNeverPositiveMatches() throws {
        let value = LockedContainer(0)
        deferToMainQueue { value.set(1) }
        try require { value.value }.toNever(beGreaterThan(1))

        deferToMainQueue { value.set(0) }
        try require { value.value }.neverTo(beGreaterThan(1))
    }

    func testToNeverNegativeMatches() {
        let value = LockedContainer(0)
        failsWithErrorMessage("expected to never equal <0>, got <0>") {
            try require { value.value }.toNever(equal(0))
        }
        failsWithErrorMessage("expected to never equal <0>, got <0>") {
            try require { value.value }.neverTo(equal(0))
        }
        failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value.set(1) }
            try require { value.value }.toNever(equal(1))
        }
        failsWithErrorMessage("expected to never equal <1>, got <1>") {
            deferToMainQueue { value.set(1) }
            try require { value.value }.neverTo(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.toNever(equal(0))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.neverTo(equal(0))
        }
        failsWithErrorMessage("expected to never equal <1>, got <1>") {
            try require(1).toNever(equal(1))
        }
    }

    func testToAlwaysPositiveMatches() throws {
        let value = LockedContainer(1)
        deferToMainQueue { value.set(2) }
        try require { value.value }.toAlways(beGreaterThan(0))

        deferToMainQueue { value.set(2) }
        try require { value.value }.alwaysTo(beGreaterThan(1))
    }

    func testToAlwaysNegativeMatches() {
        let value = LockedContainer(1)
        failsWithErrorMessage("expected to always equal <0>, got <1>") {
            try require { value.value }.toAlways(equal(0))
        }
        failsWithErrorMessage("expected to always equal <0>, got <1>") {
            try require { value.value }.alwaysTo(equal(0))
        }
        failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value.set(0) }
            try require { value.value }.toAlways(equal(1))
        }
        failsWithErrorMessage("expected to always equal <1>, got <0>") {
            deferToMainQueue { value.set(0) }
            try require { value.value }.alwaysTo(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.toAlways(equal(0))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            try require { try self.doThrowError() }.alwaysTo(equal(0))
        }
        failsWithErrorMessage("expected to always equal <1>, got <nil> (use beNil() to match nils)") {
            try require(nil).toAlways(equal(1))
        }
    }

    func testPollUnwrapMessage() {
        failsWithErrorMessage("expected to eventually not be nil, got <nil>") {
            try pollUnwrap(timeout: .milliseconds(100)) { nil as Int? }
        }

        failsWithErrorMessage("Custom Message\nexpected to eventually not be nil, got <nil>") {
            try pollUnwrap(timeout: .milliseconds(100), description: "Custom Message") { nil as Int? }
        }

        failsWithErrorMessage("Custom Message 2\nexpected to eventually not be nil, got <nil>") {
            try pollUnwraps(timeout: .milliseconds(100), description: "Custom Message 2") { nil as Int? }
        }
    }

    func testPollUnwrapMessageAsync() async {
        @Sendable func asyncOptional(_ value: Int?) async -> Int? {
            value
        }

        await failsWithErrorMessage("expected to eventually not be nil, got <nil>") {
            try await pollUnwrap(timeout: .milliseconds(100)) { await asyncOptional(nil) as Int? }
        }

        await failsWithErrorMessage("Custom Message\nexpected to eventually not be nil, got <nil>") {
            try await pollUnwrap(timeout: .milliseconds(100), description: "Custom Message") { await asyncOptional(nil) as Int? }
        }

        await failsWithErrorMessage("Custom Message 2\nexpected to eventually not be nil, got <nil>") {
            try await pollUnwrapa(timeout: .milliseconds(100), description: "Custom Message 2") { await asyncOptional(nil) as Int? }
        }
    }
}

#endif // #if !os(WASI)

