import XCTest
import Nimble

private struct StubError: Error, CustomDebugStringConvertible {
    let debugDescription = "StubError"
}

final class BeSuccessTest: XCTestCase {
    func testPositiveMatch() {
        let successfulResult: Result<Int, Error> = .success(1)
        expect(successfulResult).to(beSuccess())
    }

    func testPositiveMatchWithValueTesting() {
        let stubValue = 1
        let successfulResult: Result<Int, Error> = .success(stubValue)
        expect(successfulResult).to(beSuccess { value in
            expect(value).to(equal(stubValue))
        })
    }

    func testNegativeMatch() {
        let failureResult: Result<Int, Error> = .failure(StubError())
        expect(failureResult).toNot(beSuccess())
    }

    func testExpectationFailureMessage() {
        let failureResult: Result<Int, Error> = .failure(StubError())
        failsWithErrorMessage("expected to be <success>, got <failure(StubError)>") {
            expect(failureResult).to(beSuccess())
        }
    }
}

final class BeFailureTest: XCTestCase {
    func testPositiveMatch() {
        let failureResult: Result<Int, Error> = .failure(StubError())
        expect(failureResult).to(beFailure())
    }

    func testPositiveMatchWithValueTesting() {
        let failureResult: Result<Int, Error> = .failure(StubError())
        expect(failureResult).to(beFailure { value in
            expect(value).to(matchError(StubError.self))
        })
    }

    func testNegativeMatch() {
        let successfulResult: Result<Int, Error> = .success(1)
        expect(successfulResult).toNot(beFailure())
    }

    func testExpectationFailureMessage() {
        let successfulResult: Result<Int, Error> = .success(1)
        failsWithErrorMessage("expected to be <failure>, got <success(1)>") {
            expect(successfulResult).to(beFailure())
        }
    }
}
