import XCTest
import Nimble

private struct StubError: Error, CustomDebugStringConvertible {
    let debugDescription = "StubError"
}

enum TestError: Error, Equatable, CustomDebugStringConvertible {
    case a, b

    var debugDescription: String {
        switch self {
        case .a:
            return "TestError.a"
        case .b:
            return "TestError.b"
        }
    }
}

final class BeSuccessTest: XCTestCase {
    func testPositiveMatch() {
        let result: Result<Int, Error> = .success(1)
        expect(result).to(beSuccess())
    }

    func testPositiveMatchWithClosure() {
        let stubValue = 1
        let result: Result<Int, Error> = .success(stubValue)
        expect(result).to(beSuccess { value in
            expect(value).to(equal(stubValue))
        })
    }

    func testPositiveNegatedMatch() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).toNot(beSuccess())
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to be <success(Int)>, got <failure(StubError)>") {
            let result: Result<Int, Error> = .failure(StubError())
            expect(result).to(beSuccess())
        }
        failsWithErrorMessage("expected to not be <success(Int)>, got <success(1)>") {
            let result: Result<Int, Error> = .success(1)
            expect(result).toNot(beSuccess())
        }

        failsWithErrorMessage("expected to be <success(Int)> that satisfies block, got <success(1)>") {
            let result: Result<Int, Error> = .success(1)
            expect(result).to(beSuccess() { _ in
                fail()
            })
        }
    }
}

final class BeFailureTest: XCTestCase {
    func testPositiveMatch() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).to(beFailure())
    }

    func testPositiveMatchWithClosure() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).to(beFailure { error in
            expect(error).to(matchError(StubError.self))
        })

        expect(Result<Int, TestError>.failure(.a)).to(beFailure { error in
            expect(error).to(equal(.a))
        })
    }

    func testPositiveNegatedMatch() {
        let result: Result<Int, Error> = .success(1)
        expect(result).toNot(beFailure())
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to be <failure(Error)>, got <success(1)>") {
            let result: Result<Int, Error> = .success(1)
            expect(result).to(beFailure())
        }
        failsWithErrorMessage("expected to not be <failure(Error)>, got <failure(StubError)>") {
            let result: Result<Int, Error> = .failure(StubError())
            expect(result).toNot(beFailure())
        }

        failsWithErrorMessage("expected to be <failure(Error)> that satisfies block, got <failure(StubError)>") {
            let result: Result<Int, Error> = .failure(StubError())
            expect(result).to(beFailure() { _ in
                fail()
            })
        }
        failsWithErrorMessage("expected to be <failure(TestError)> that satisfies block, got <failure(TestError.a)>") {
            let result: Result<Int, TestError> = .failure(.a)
            expect(result).to(beFailure() { error in
                expect(error).to(equal(.b))
            })
        }
    }
}
