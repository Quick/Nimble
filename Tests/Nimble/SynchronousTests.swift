import Foundation
import XCTest
import Nimble

class SynchronousTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testFailAlwaysFails", testFailAlwaysFails),
            ("testUnexpectedErrorsThrownFails", testUnexpectedErrorsThrownFails),
            ("testToMatchesIfMatcherReturnsTrue", testToMatchesIfMatcherReturnsTrue),
            ("testToProvidesActualValueExpression", testToProvidesActualValueExpression),
            ("testToProvidesAMemoizedActualValueExpression", testToProvidesActualValueExpression),
            ("testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl", testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl),
            ("testToMatchAgainstLazyProperties", testToMatchAgainstLazyProperties),
            ("testToNotMatchesIfMatcherReturnsTrue", testToNotMatchesIfMatcherReturnsTrue),
            ("testToNotProvidesActualValueExpression", testToNotProvidesActualValueExpression),
            ("testToNotProvidesAMemoizedActualValueExpression", testToNotProvidesAMemoizedActualValueExpression),
            ("testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl", testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl),
            ("testToNotNegativeMatches", testToNotNegativeMatches),
            ("testNotToMatchesLikeToNot", testNotToMatchesLikeToNot),
        ]
    }

    let errorToThrow = NSError(domain: NSCocoaErrorDomain, code: 42, userInfo: nil)
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
#if _runtime(_ObjC) // This test triggers a weird segfault on Linux currently
        failsWithErrorMessage("expected to equal <1>, got an unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.to(equal(1))
        }
        failsWithErrorMessage("expected to not equal <1>, got an unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toNot(equal(1))
        }
#endif
    }

    func testToMatchesIfMatcherReturnsTrue() {
        expect(1).to(MatcherFunc { expr, failure in true })
        expect{1}.to(MatcherFunc { expr, failure in true })
    }

    func testToProvidesActualValueExpression() {
        var value: Int?
        expect(1).to(MatcherFunc { expr, failure in value = try expr.evaluate(); return true })
        expect(value).to(equal(1))
    }

    func testToProvidesAMemoizedActualValueExpression() {
        var callCount = 0
        expect{ callCount += 1 }.to(MatcherFunc { expr, failure in
            try expr.evaluate()
            try expr.evaluate()
            return true
        })
        expect(callCount).to(equal(1))
    }

    func testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        var callCount = 0
        expect{ callCount += 1 }.to(MatcherFunc { expr, failure in
            expect(callCount).to(equal(0))
            try expr.evaluate()
            return true
        })
        expect(callCount).to(equal(1))
    }

    func testToMatchAgainstLazyProperties() {
        expect(ObjectWithLazyProperty().value).to(equal("hello"))
        expect(ObjectWithLazyProperty().value).toNot(equal("world"))
        expect(ObjectWithLazyProperty().anotherValue).to(equal("world"))
        expect(ObjectWithLazyProperty().anotherValue).toNot(equal("hello"))
    }

    // repeated tests from to() for toNot()
    func testToNotMatchesIfMatcherReturnsTrue() {
        expect(1).toNot(MatcherFunc { expr, failure in false })
        expect{1}.toNot(MatcherFunc { expr, failure in false })
    }

    func testToNotProvidesActualValueExpression() {
        var value: Int?
        expect(1).toNot(MatcherFunc { expr, failure in value = try expr.evaluate(); return false })
        expect(value).to(equal(1))
    }

    func testToNotProvidesAMemoizedActualValueExpression() {
        var callCount = 0
        expect{ callCount += 1 }.toNot(MatcherFunc { expr, failure in
            try expr.evaluate()
            try expr.evaluate()
            return false
        })
        expect(callCount).to(equal(1))
    }

    func testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        var callCount = 0
        expect{ callCount += 1 }.toNot(MatcherFunc { expr, failure in
            expect(callCount).to(equal(0))
            try expr.evaluate()
            return false
        })
        expect(callCount).to(equal(1))
    }

    func testToNotNegativeMatches() {
        failsWithErrorMessage("expected to not match, got <1>") {
            expect(1).toNot(MatcherFunc { expr, failure in true })
        }
    }


    func testNotToMatchesLikeToNot() {
        expect(1).notTo(MatcherFunc { expr, failure in false })
    }
}
