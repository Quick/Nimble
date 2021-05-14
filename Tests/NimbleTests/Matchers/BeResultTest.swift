import XCTest
import Nimble

private struct StubError: Error, CustomDebugStringConvertible {
    let debugDescription = "StubError"
}

final class BeSuccessTest: XCTestCase {
    func testPositiveMatch() {
        let result: Result<Int, Error> = .success(1)
        expect(result).to(beSuccess())
    }

    func testPositiveMatchWithValueTesting() {
        let stubValue = 1
        let result: Result<Int, Error> = .success(stubValue)
        expect(result).to(beSuccess { value in
            expect(value).to(equal(stubValue))
        })
    }

    func testNegativeMatch() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).toNot(beSuccess())
    }

    func testExpectationFailureMessage() {
        failsWithErrorMessage("expected to be <success(Int)>, got <failure(StubError)>") {
            let result: Result<Int, Error> = .failure(StubError())
            expect(result).to(beSuccess())
        }
    }
}

final class BeFailureTest: XCTestCase {
    func testPositiveMatch() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).to(beFailure())
    }

    func testPositiveMatchWithValueTesting() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).to(beFailure { error in
            expect(error).to(matchError(StubError.self))
        })
    }

    func testNegativeMatch() {
        let result: Result<Int, Error> = .success(1)
        expect(result).toNot(beFailure())
    }

    func testExpectationFailureMessage() {
        failsWithErrorMessage("expected to be <failure(Error)>, got <success(1)>") {
            let result: Result<Int, Error> = .success(1)
            expect(result).to(beFailure())
        }
    }
}
