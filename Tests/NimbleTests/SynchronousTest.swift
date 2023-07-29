import Foundation
import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class SynchronousTest: XCTestCase {
    class Error: Swift.Error {}
    let errorToThrow = Error()

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testFailAlwaysFails() {
        failsWithErrorMessage("My error message") {
            fail("My error message")
        }
        failsWithErrorMessage("fail() always fails") {
            fail()
        }
    }

    func testUnexpectedErrorsThrownFails() {
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.to(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toNot(equal(1))
        }
    }

    func testToMatchesIfMatcherReturnsTrue() {
        expect(1).to(Predicate.simple { _ in .matches })
        expect {1}.to(Predicate.simple { _ in .matches })
    }

    func testToProvidesActualValueExpression() {
        let recorder = Recorder<Int?>()
        expect(1).to(Predicate.simple { expr in recorder.record(try expr.evaluate()); return .matches })
        expect(recorder.records).to(equal([1]))
    }

    func testToProvidesAMemoizedActualValueExpression() {
        let recorder = Recorder<Void>()
        expect {
            recorder.record(())
        }.to(Predicate.simple { expr in
            _ = try expr.evaluate()
            _ = try expr.evaluate()
            return .matches
        })
        expect(recorder.records).to(haveCount(1))
    }

    func testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        let recorder = Recorder<Void>()
        expect {
            recorder.record(())
        }.to(Predicate.simple { expr in
            expect(recorder.records).to(beEmpty())
            _ = try expr.evaluate()
            return .matches
        })
        expect(recorder.records).to(haveCount(1))
    }

    func testToMatchAgainstLazyProperties() {
        expect(ObjectWithLazyProperty().value).to(equal("hello"))
        expect(ObjectWithLazyProperty().value).toNot(equal("world"))
        expect(ObjectWithLazyProperty().anotherValue).to(equal("world"))
        expect(ObjectWithLazyProperty().anotherValue).toNot(equal("hello"))
    }

    // repeated tests from to() for toNot()
    func testToNotMatchesIfMatcherReturnsTrue() {
        expect(1).toNot(Predicate.simple { _ in .doesNotMatch })
        expect {1}.toNot(Predicate.simple { _ in .doesNotMatch })
    }

    func testToNotProvidesActualValueExpression() {
        let recorder = Recorder<Int?>()
        expect(1).toNot(Predicate.simple { expr in recorder.record(try expr.evaluate()); return .doesNotMatch })
        expect(recorder.records).to(equal([1]))
    }

    func testToNotProvidesAMemoizedActualValueExpression() {
        let recorder = Recorder<Void>()
        expect { recorder.record(()) }.toNot(Predicate.simple { expr in
            _ = try expr.evaluate()
            _ = try expr.evaluate()
            return .doesNotMatch
        })
        expect(recorder.records).to(haveCount(1))
    }

    func testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        let recorder = Recorder<Void>()
        expect { recorder.record(()) }.toNot(Predicate.simple { expr in
            expect(recorder.records).to(beEmpty())
            _ = try expr.evaluate()
            return .doesNotMatch
        })
        expect(recorder.records).to(haveCount(1))
    }

    func testToNegativeMatches() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Predicate.simple { _ in .doesNotMatch })
        }
    }

    func testToNotNegativeMatches() {
        failsWithErrorMessage("expected to not match, got <1>") {
            expect(1).toNot(Predicate.simple { _ in .matches })
        }
    }

    func testNotToMatchesLikeToNot() {
        expect(1).notTo(Predicate.simple { _ in .doesNotMatch })
    }

    // MARK: Assertion chaining

    func testChain() {
        expect(2).toNot(equal(1)).to(equal(2)).notTo(equal(3))
    }

    func testChainFail() {
        failsWithErrorMessage(["expected to not equal <2>, got <2>", "expected to equal <3>, got <2>"]) {
            expect(2).toNot(equal(1)).toNot(equal(2)).to(equal(3))
        }
    }
}

private final class Recorder<T: Sendable>: @unchecked Sendable {
    private var _records: [T] = []
    private let lock = NSRecursiveLock()

    var records: [T] {
        get {
            lock.lock()
            defer {
                lock.unlock()
            }
            return _records
        }
    }

    func record(_ value: T) {
        lock.lock()
        self._records.append(value)
        lock.unlock()
    }
}
