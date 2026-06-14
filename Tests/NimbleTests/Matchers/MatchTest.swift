import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class MatchTest: XCTestCase {
    func testMatchPositive() {
        expect("11:14").to(match("\\d{2}:\\d{2}"))
    }

    func testMatchNegative() {
        expect("hello").toNot(match("\\d{2}:\\d{2}"))
    }

    func testMatchPositiveMessage() {
        let message = "expected to match <\\d{2}:\\d{2}>, got <hello>"
        failsWithErrorMessage(message) {
            expect("hello").to(match("\\d{2}:\\d{2}"))
        }
    }

    func testMatchNegativeMessage() {
        let message = "expected to not match <\\d{2}:\\d{2}>, got <11:14>"
        failsWithErrorMessage(message) {
            expect("11:14").toNot(match("\\d{2}:\\d{2}"))
        }
    }

    func testMatchNils() {
        failsWithErrorMessageForNil("expected to match <\\d{2}:\\d{2}>, got <nil>") {
            expect(nil as String?).to(match("\\d{2}:\\d{2}"))
        }

        failsWithErrorMessageForNil("expected to not match <\\d{2}:\\d{2}>, got <nil>") {
            expect(nil as String?).toNot(match("\\d{2}:\\d{2}"))
        }
    }

    func testMatcherDefersErrorMessageEvaluation() {
        var errorEvaluationCount = 0
        func makeErrorMessage() -> String {
            errorEvaluationCount += 1
            return "create error message #\(errorEvaluationCount)"
        }

        let match: Matcher<Int> = Matcher.define { expression in
            _ = try expression.evaluate()
            return MatcherResult(
                status: .matches,
                message: .expectedTo(makeErrorMessage()).prepended(expectation: "not")
            )
        }
        expect(1).to(match)
        expect(errorEvaluationCount).to(equal(0))

        let doesNotMatch: Matcher<Int> = Matcher.define { expression in
            _ = try expression.evaluate()
            return MatcherResult(
                status: .doesNotMatch,
                message: .expectedTo(makeErrorMessage())
            )
        }
        expect(1).toNot(doesNotMatch)
        expect(errorEvaluationCount).to(equal(0))

        let fail: Matcher<Int> = Matcher.define { expression in
            _ = try expression.evaluate()
            return MatcherResult(
                status: .fail,
                message: .expectedTo(makeErrorMessage())
            )
        }
        failsWithErrorMessage("expected to not create error message #1") {
            expect(1).toNot(fail)
        }
        expect(errorEvaluationCount).to(equal(1))
    }

    func testSimpleMatcherDefersErrorMessageEvaluation() {
        var errorEvaluationCount = 0
        func makeErrorMessage() -> String {
            errorEvaluationCount += 1
            return "create error message #\(errorEvaluationCount)"
        }

        let match: Matcher<Int> = Matcher.simple(makeErrorMessage()) { expression in
            _ = try expression.evaluate()
            return .matches
        }
        expect(1).to(match)
        expect(errorEvaluationCount).to(equal(0))

        let doesNotMatch: Matcher<Int> = Matcher.simple(makeErrorMessage()) { expression in
            _ = try expression.evaluate()
            return .doesNotMatch
        }
        expect(1).toNot(doesNotMatch)
        expect(errorEvaluationCount).to(equal(0))

        let fail: Matcher<Int> = Matcher.simple(makeErrorMessage()) { expression in
            _ = try expression.evaluate()
            return .fail
        }
        failsWithErrorMessage("expected to not create error message #1, got <1>") {
            expect(1).toNot(fail)
        }
        expect(errorEvaluationCount).to(equal(1))
    }
}
