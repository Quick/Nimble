import XCTest
import Nimble

private func nonThrowingInt() -> Int {
    return 1
}

private func throwingInt() throws -> Int {
    return 1
}

private func nonThrowingAsyncInt() async -> Int {
    return 1
}

private func throwingAsyncInt() async throws -> Int {
    return 1
}

final class DSLTest: XCTestCase {
    // MARK: - Expect
    func testExpectAutoclosureNonThrowing() {
        let _: SyncExpectation<Int> = expect(1)
        let _: SyncExpectation<Int> = expect(nonThrowingInt())
    }

    func testExpectAutoclosureThrowing() {
        let _: SyncExpectation<Int> = expect(try throwingInt())
    }

    func testExpectClosure() {
        let _: SyncExpectation<Int> = expect { 1 }
        let _: SyncExpectation<Int> = expect { nonThrowingInt() }
        let _: SyncExpectation<Int> = expect { try throwingInt() }
        let _: SyncExpectation<Int> = expect { () -> Int in 1 }
        let _: SyncExpectation<Int> = expect { () -> Int? in 1 }
        let _: SyncExpectation<Int> = expect { () -> Int? in nil }

        let _: SyncExpectation<Void> = expect { }
        let _: SyncExpectation<Void> = expect { () -> Void in }

        let _: SyncExpectation<Void> = expect { return }
        let _: SyncExpectation<Void> = expect { () -> Void in return }

        let _: SyncExpectation<Void> = expect { return () }
        let _: SyncExpectation<Void> = expect { () -> Void in return () }
    }

    func testExpectAsyncClosure() async {
        let _: AsyncExpectation<Int> = expect { 1 }
        let _: AsyncExpectation<Int> = expect { await nonThrowingAsyncInt() }
        let _: AsyncExpectation<Int> = expect { try await throwingAsyncInt() }
        let _: AsyncExpectation<Int> = expect { () -> Int in 1 }
        let _: AsyncExpectation<Int> = expect { () -> Int? in 1 }
        let _: AsyncExpectation<Int> = expect { () -> Int? in nil }

        let _: AsyncExpectation<Void> = expect { }
        let _: AsyncExpectation<Void> = expect { () -> Void in }

        let _: AsyncExpectation<Void> = expect { return }
        let _: AsyncExpectation<Void> = expect { () -> Void in return }

        let _: AsyncExpectation<Void> = expect { return () }
        let _: AsyncExpectation<Void> = expect { () -> Void in return () }
    }

    func testExpectCombinedSyncAndAsyncExpects() async {
        await expect { await nonThrowingAsyncInt() }.to(equal(1))
        await expecta(await nonThrowingAsyncInt()).to(equal(1))
        expect(1).to(equal(1))

        expect { nonThrowingInt() }.to(equal(1))
        expects { nonThrowingInt() }.to(equal(1))
    }

    // MARK: - Require
    func testRequireAutoclosureNonThrowing() {
        let _: SyncRequirement<Int> = require(1)
        let _: SyncRequirement<Int> = require(nonThrowingInt())
    }

    func testRequireAutoclosureThrowing() {
        let _: SyncRequirement<Int> = require(try throwingInt())
    }

    func testRequireClosure() {
        let _: SyncRequirement<Int> = require { 1 }
        let _: SyncRequirement<Int> = require { nonThrowingInt() }
        let _: SyncRequirement<Int> = require { try throwingInt() }
        let _: SyncRequirement<Int> = require { () -> Int in 1 }
        let _: SyncRequirement<Int> = require { () -> Int? in 1 }
        let _: SyncRequirement<Int> = require { () -> Int? in nil }

        let _: SyncRequirement<Void> = require { }
        let _: SyncRequirement<Void> = require { () -> Void in }

        let _: SyncRequirement<Void> = require { return }
        let _: SyncRequirement<Void> = require { () -> Void in return }

        let _: SyncRequirement<Void> = require { return () }
        let _: SyncRequirement<Void> = require { () -> Void in return () }
    }

    func testRequireAsyncClosure() async {
        let _: AsyncRequirement<Int> = require { 1 }
        let _: AsyncRequirement<Int> = require { await nonThrowingAsyncInt() }
        let _: AsyncRequirement<Int> = require { try await throwingAsyncInt() }
        let _: AsyncRequirement<Int> = require { () -> Int in 1 }
        let _: AsyncRequirement<Int> = require { () -> Int? in 1 }
        let _: AsyncRequirement<Int> = require { () -> Int? in nil }

        let _: AsyncRequirement<Void> = require { }
        let _: AsyncRequirement<Void> = require { () -> Void in }

        let _: AsyncRequirement<Void> = require { return }
        let _: AsyncRequirement<Void> = require { () -> Void in return }

        let _: AsyncRequirement<Void> = require { return () }
        let _: AsyncRequirement<Void> = require { () -> Void in return () }
    }

    func testExpectCombinedSyncAndAsyncRequirements() async throws {
        try await require { await nonThrowingAsyncInt() }.to(equal(1))
        try await requirea(await nonThrowingAsyncInt()).to(equal(1))
        try require(1).to(equal(1))

        try require { nonThrowingInt() }.to(equal(1))
    }

    func testRequire() {
        expect { try require(1).to(equal(1)) }.to(equal(1))
        expect { try require(3).toNot(beNil()) }.to(equal(3))

        let records = gatherExpectations(silently: true) {
            do {
                try require(1).to(equal(2))
            } catch {
                expect(error).to(matchError(RequireError.self))
            }
        }

        expect(records).to(haveCount(2))
        expect(records.first?.success).to(beFalse())
        expect(records.last?.success).to(beTrue())
    }

    func testRequireWithCustomError() {
        struct MyCustomError: Error {}

        let records = gatherExpectations(silently: true) {
            do {
                try require(customError: MyCustomError(), 1).to(equal(2))
                fail("require did not throw an error")
            } catch {
                expect(error).to(matchError(MyCustomError.self))
            }
        }

        expect(records).to(haveCount(2))
        expect(records.first?.success).to(beFalse())
        expect(records.last?.success).to(beTrue())
    }

    func testAsyncRequireWithCustomError() async {
        struct MyCustomError: Error {}

        let records = await gatherExpectations(silently: true) {
            do {
                try await requirea(customError: MyCustomError(), 1).to(equal(2))
                fail("require did not throw an error")
            } catch {
                expect(error as? MyCustomError).toNot(beNil())
            }
        }

        expect(records).to(haveCount(2))
        expect(records.first?.success).to(beFalse())
        expect(records.last?.success).to(beTrue())
    }
}
