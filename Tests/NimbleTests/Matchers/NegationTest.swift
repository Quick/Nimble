import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class NegationTest: XCTestCase {
    func testSyncNil() {
        expect(nil as Int?).toNot(not(beNil()))

        failsWithErrorMessage("expected to not be nil, got <nil>") {
            expect(nil as Int?).to(not(beNil()))
        }
    }

    func testSyncNonNil() {
        expect(1).to(not(equal(2)))

        failsWithErrorMessage("expected to not equal <2>, got <2>") {
            expect(2).to(not(equal(2)))
        }
    }

    func testAsyncNil() async {
        @Sendable func nilFunc() async -> Int? {
            nil
        }

        await expect(nilFunc).toNot(not(beNil()))

        await failsWithErrorMessage("expected to not be nil, got <nil>") {
            await expect(nilFunc).to(not(beNil()))
        }
    }

    func testAsyncNonNil() async {
        await expect(1).to(not(asyncEqual(2)))

        await failsWithErrorMessage("expected to not equal 2, got <2>") {
            await expect(2).to(not(asyncEqual(2)))
        }
    }
}
