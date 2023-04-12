import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class OnFailureThrowsTest: XCTestCase {

    enum MyError: Error, Equatable {
        case error1
    }

    func testUnexecutedLogsAnError() {
        failsWithErrorMessage("Attempted to call `Expectation.onFailure(throw:) before a predicate has been applied.\nTry using `expect(...).to(...).onFailure(throw: ...`) instead.") {
            try expect(true).onFailure(throw: MyError.error1)
        }
    }

    func testPassedDoesNotThrow() {
        let expectation = expect(true).to(beTrue())

        expect(try expectation.onFailure(throw: MyError.error1)).notTo(throwError())
    }

    func testFailedThrowsAnError() {
        let expectation = suppressErrors {
            expect(true).to(beFalse())
        }

        expect(try expectation.onFailure(throw: MyError.error1)).to(throwError(MyError.error1))
    }

    func testMixedThrowsAnError() {
        let expectation = suppressErrors {
            expect(true).to(beTrue()).to(beFalse())
        }

        expect(try expectation.onFailure(throw: MyError.error1)).to(throwError(MyError.error1))
    }
}
