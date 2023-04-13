import XCTest
import Nimble
import Foundation
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class SatisfyAnyOfTest: XCTestCase {
    func testSatisfyAnyOf() {
        expect(2).to(satisfyAnyOf(equal(2), equal(3)))
        expect(2 as NSNumber).toNot(satisfyAnyOf(equal(3 as NSNumber), equal("turtles" as NSString)))
        expect([1, 2, 3]).to(satisfyAnyOf(equal([1, 2, 3]), allPass({$0 < 4}), haveCount(3)))
        expect("turtle").toNot(satisfyAnyOf(contain("a"), endWith("magic")))
        expect(82.0).toNot(satisfyAnyOf(beLessThan(10.5), beGreaterThan(100.75), beCloseTo(50.1)))
        expect(false).to(satisfyAnyOf(beTrue(), beFalse()))
        expect(true).to(satisfyAnyOf(beTruthy(), beFalsy()))

        failsWithErrorMessage(
            "expected to match one of: {equal <3>}, or {equal <4>}, or {equal <5>}, got 2") {
                expect(2).to(satisfyAnyOf(equal(3), equal(4), equal(5)))
        }
        failsWithErrorMessage(
            "expected to match one of: {all be less than 4, but failed first at element <5> in <[5, 6, 7]>}, or {equal <[1, 2, 3, 4]>}, got [5, 6, 7]") {
                expect([5, 6, 7]).to(satisfyAnyOf(allPass("be less than 4", {$0 < 4}), equal([1, 2, 3, 4])))
        }
        failsWithErrorMessage(
            "expected to match one of: {be true}, got false") {
                expect(false).to(satisfyAnyOf(beTrue()))
        }
        failsWithErrorMessage(
            "expected to not match one of: {be less than <10.5>}, or {be greater than <100.75>}, or {be close to <50.1> (within 0.0001)}, got 50.10001") {
                expect(50.10001).toNot(satisfyAnyOf(beLessThan(10.5), beGreaterThan(100.75), beCloseTo(50.1)))
        }
        failsWithErrorMessage(
            "expected to match one of: {This matcher should always fail}, or {This matcher should always fail}, got true") {
            expect(true).to(satisfyAnyOf(alwaysFail(), alwaysFail()))
        }
        failsWithErrorMessage(
            "expected to not match one of: {This matcher should always fail}, or {This matcher should always fail}, got true") {
            expect(true).toNot(satisfyAnyOf(alwaysFail(), alwaysFail()))
        }
    }

    func testOperatorOr() {
        expect(2).to(equal(2) || equal(3))
        expect(2 as NSNumber).toNot(equal(3 as NSNumber) || equal("turtles" as NSString))
        expect("turtle").toNot(contain("a") || endWith("magic"))
        expect(82.0).toNot(beLessThan(10.5) || beGreaterThan(100.75))
        expect(false).to(beTrue() || beFalse())
        expect(true).to(beTruthy() || beFalsy())
    }

    func testSatisfyAllOfCachesExpressionBeforePassingToPredicates() {
        // This is not a great example of assertion writing - functions being asserted on in Expressions should not have side effects.
        // But we should still handle those cases anyway.
        var value: Int = 0
        func testFunction() -> Int {
            value += 1
            return value
        }

        // This demonstrates caching because the first time this is evaluated, the function should return 1, which doesn't pass the `equal(0)`.
        // Next time, it'll return 2, which doesn't pass the `equal(1)`.
        expect(testFunction()).toEventually(satisfyAnyOf(equal(0), equal(1)))
    }
}
