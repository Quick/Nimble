import XCTest
import Nimble
import Foundation
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class SatisfyAllOfTest: XCTestCase {
    func testSatisfyAllOf() {
        expect(2).to(satisfyAllOf(equal(2), beLessThan(3)))
        expect(2 as NSNumber).toNot(satisfyAllOf(equal(3 as NSNumber), equal("turtles" as NSString)))
        expect([1, 2, 3]).to(satisfyAllOf(equal([1, 2, 3]), allPass({$0 < 4}), haveCount(3)))
        expect("turtle").to(satisfyAllOf(contain("e"), beginWith("tur")))
        expect(82.0).to(satisfyAllOf(beGreaterThan(10.5), beLessThan(100.75), beCloseTo(82.00001)))
        expect(false).toNot(satisfyAllOf(beTrue(), beFalse()))
        expect(true).toNot(satisfyAllOf(beTruthy(), beFalsy()))

        failsWithErrorMessage(
        "expected to match all of: {equal <3>}, and {equal <4>}, and {equal <5>}, got 2") {
            expect(2).to(satisfyAllOf(equal(3), equal(4), equal(5)))
        }
        failsWithErrorMessage(
        "expected to match all of: {all be less than 4, but failed first at element <5> in <[5, 6, 7]>}, and {equal <[5, 6, 7]>}, got [5, 6, 7]") {
            expect([5, 6, 7]).to(satisfyAllOf(allPass("be less than 4", {$0 < 4}), equal([5, 6, 7])))
        }
        failsWithErrorMessage(
        "expected to not match all of: {be false}, got false") {
            expect(false).toNot(satisfyAllOf(beFalse()))
        }
        failsWithErrorMessage(
        "expected to not match all of: {be greater than <10.5>}, and {be less than <100.75>}, and {be close to <50.1> (within 0.0001)}, got 50.10001") {
            expect(50.10001).toNot(satisfyAllOf(beGreaterThan(10.5), beLessThan(100.75), beCloseTo(50.1)))
        }
        failsWithErrorMessage(
        "expected to not match all of: {This matcher should always fail}, and {This matcher should always fail}, got true") {
            expect(true).toNot(satisfyAllOf(alwaysFail(), alwaysFail()))
        }
        failsWithErrorMessage(
        "expected to match all of: {This matcher should always fail}, and {This matcher should always fail}, got true") {
            expect(true).to(satisfyAllOf(alwaysFail(), alwaysFail()))
        }
    }

    func testOperatorAnd() {
        expect(2).to(equal(2) && beLessThan(3))
        expect(2).to(beLessThan(3) && beGreaterThan(1))
        expect(2 as NSNumber).to(beLessThan(3 as NSNumber) && beGreaterThan(1 as NSNumber))
        expect("turtle").to(contain("t") && endWith("tle"))
        expect(82.0).to(beGreaterThan(10.5) && beLessThan(100.75))
        expect(false).to(beFalsy() && beFalse())
        expect(false).toNot(beTrue() && beFalse())
        expect(true).toNot(beTruthy() && beFalsy())
    }

    func testSatisfyAllOfCachesExpressionBeforePassingToPredicates() {
        // This is not a great example of assertion writing - functions being asserted on in Expressions should not have side effects.
        // But we should still handle those cases anyway.
        var value: Int = 0
        func testFunction() -> Int {
            value += 1
            return value
        }

        expect(testFunction()).toEventually(satisfyAllOf(equal(1), equal(1)))
    }
}
