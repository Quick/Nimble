import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

private struct StubError: Error, CustomDebugStringConvertible {
    let debugDescription = "StubError"
}

enum TestError: Error, Equatable, CustomDebugStringConvertible {
    case foo, bar

    var debugDescription: String {
        switch self {
        case .foo:
            return "TestError.foo"
        case .bar:
            return "TestError.bar"
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
            expect(result).to(beSuccess { _ in
                fail()
            })
        }
    }
}

final class BeSuccessWithMatcherTest: XCTestCase {
    func testPositiveMatch() {
        let result: Result<Int, Error> = .success(1)
        expect(result).to(beSuccess(equal(1)))
    }

    func testPositiveNegatedMatch() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).toNot(beSuccess(equal(1)))

        expect(Result<Int, Error>.success(2)).toNot(beSuccess(equal(1)))
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to be <success(Int)> that satisfies matcher, got <failure(StubError)>") {
            let result: Result<Int, Error> = .failure(StubError())
            expect(result).to(beSuccess(equal(1)))
        }
        failsWithErrorMessage("expected to be <success(Int)> that satisfies matcher, got <success(1)>\nexpected to equal <2>, got 1") {
            let result: Result<Int, Error> = .success(1)
            expect(result).to(beSuccess(equal(2)))
        }
    }
}

final class BeSuccessWithEquatableTest: XCTestCase {
    func testPositiveMatch() {
        let result: Result<Int, Error> = .success(1)
        expect(result).to(beSuccess(1))
    }

    func testPositiveNegatedMatch() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).toNot(beSuccess(1))

        expect(Result<Int, Error>.success(2)).toNot(beSuccess(1))
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to be <success(Int)> that equals 1, got <failure(StubError)>") {
            let result: Result<Int, Error> = .failure(StubError())
            expect(result).to(beSuccess(1))
        }
        failsWithErrorMessage("expected to be <success(Int)> that equals 2, got <success(1)>") {
            let result: Result<Int, Error> = .success(1)
            expect(result).to(beSuccess(2))
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

        expect(Result<Int, TestError>.failure(.foo)).to(beFailure { error in
            expect(error).to(equal(.foo))
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
            expect(result).to(beFailure { _ in
                fail()
            })
        }
        failsWithErrorMessage("expected to be <failure(TestError)> that satisfies block, got <failure(TestError.foo)>") {
            let result: Result<Int, TestError> = .failure(.foo)
            expect(result).to(beFailure { error in
                expect(error).to(equal(.bar))
            })
        }
    }
}

final class BeFailureWithMatcherTest: XCTestCase {
    func testPositiveMatch() {
        let result: Result<Int, Error> = .failure(StubError())
        expect(result).to(beFailure(matchError(StubError())))
    }

    func testPositiveNegatedMatch() {
        let result: Result<Int, Error> = .success(1)
        expect(result).toNot(beFailure(matchError(StubError())))

        expect(
            Result<Int, Error>.failure(TestError.foo)
        ).toNot(beFailure(matchError(StubError())))
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to be <failure(Error)> that satisfies matcher, got <success(1)>") {
            let result: Result<Int, Error> = .success(1)
            expect(result).to(beFailure(matchError(StubError())))
        }
        failsWithErrorMessage("expected to be <failure(Error)> that satisfies matcher, got <failure(StubError)>\nexpected to match error <TestError.foo>, got <StubError>") {
            let result: Result<Int, Error> = .failure(StubError())
            expect(result).to(beFailure(matchError(TestError.foo)))
        }
        failsWithErrorMessage("expected to be <failure(TestError)> that satisfies matcher, got <failure(TestError.foo)>\nexpected to equal <TestError.bar>, got TestError.foo") {
            let result: Result<Int, TestError> = .failure(.foo)
            expect(result).to(beFailure(equal(TestError.bar)))
        }
    }
}
