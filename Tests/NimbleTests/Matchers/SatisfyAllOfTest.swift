import XCTest
import Nimble
import Foundation
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class SatisfyAllOfTest: XCTestCase {
    // MARK: - synchronous variant
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

    #if !os(WASI)
    func testSatisfyAllOfCachesExpressionBeforePassingToMatchers() {
        // This is not a great example of assertion writing - functions being asserted on in Expressions should not have side effects.
        // But we should still handle those cases anyway.
        var value: Int = 0
        func testFunction() -> Int {
            value += 1
            return value
        }

        expect(testFunction()).toEventually(satisfyAllOf(equal(1), equal(1)))
    }
    #endif

    // There's a compiler bug in swift 5.7.2 and earlier (xcode 14.2 and earlier)
    // which causes runtime crashes when you use `[any AsyncableMatcher<T>]`.
    // https://github.com/apple/swift/issues/61403
    #if swift(>=5.8.0)
    // MARK: - AsyncMatcher variant
    @available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
    func testAsyncSatisfyAllOf() async {
        await expect(2).to(satisfyAllOf(asyncEqual(2), beLessThan(3)))
        await expect(2 as NSNumber).toNot(satisfyAllOf(asyncEqual(3 as NSNumber), equal("turtles" as NSString)))
        await expect([1, 2, 3]).to(satisfyAllOf(asyncEqual([1, 2, 3]), allPass({$0 < 4}), haveCount(3)))
        await expect("turtle").to(satisfyAllOf(asyncContain("e"), beginWith("tur")))
        await expect(82.0).to(satisfyAllOf(beGreaterThan(10.5), beLessThan(100.75), beCloseTo(82.00001), asyncEqual(82.0)))
        await expect(false).toNot(satisfyAllOf(beTrue(), beFalse(), asyncEqual(false)))
        await expect(true).toNot(satisfyAllOf(beTruthy(), beFalsy(), asyncEqual(true)))

        await failsWithErrorMessage(
        "expected to match all of: {equal <3>}, and {equal <4>}, and {equal <5>}, got 2") {
            await expect(2).to(satisfyAllOf(asyncEqual(3), asyncEqual(4), asyncEqual(5)))
        }
        await failsWithErrorMessage(
        "expected to match all of: {all be less than 4, but failed first at element <5> in <[5, 6, 7]>}, and {equal <[5, 6, 7]>}, got [5, 6, 7]") {
            await expect([5, 6, 7]).to(satisfyAllOf(allPass("be less than 4", {$0 < 4}), asyncEqual([5, 6, 7])))
        }
        await failsWithErrorMessage(
        "expected to not match all of: {be false}, got false") {
            await expect(false).toNot(satisfyAllOf(beFalse()))
        }
        await failsWithErrorMessage(
        "expected to not match all of: {be greater than <10.5>}, and {be less than <100.75>}, and {be close to <50.1> (within 0.0001)}, got 50.10001") {
            await expect(50.10001).toNot(satisfyAllOf(beGreaterThan(10.5), beLessThan(100.75), asyncBeCloseTo(50.1)))
        }
        await failsWithErrorMessage(
        "expected to not match all of: {This matcher should always fail}, and {This matcher should always fail}, got true") {
            await expect(true).toNot(satisfyAllOf(asyncAlwaysFail(), alwaysFail()))
        }
        await failsWithErrorMessage(
        "expected to match all of: {This matcher should always fail}, and {This matcher should always fail}, got true") {
            await expect(true).to(satisfyAllOf(asyncAlwaysFail(), alwaysFail()))
        }
    }

    @available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
    func testAsyncOperatorAnd() async {
        await expect(2).to(asyncEqual(2) && beLessThan(3))
        await expect(2).to(beLessThan(3) && beGreaterThan(1))
        await expect(2 as NSNumber).to(beLessThan(3 as NSNumber) && beGreaterThan(1 as NSNumber))
        await expect("turtle").to(contain("t") && endWith("tle") && asyncEqual("turtle"))
        await expect(82.0).to(beGreaterThan(10.5) && beLessThan(100.75))
        await expect(false).to(beFalsy() && beFalse())
        await expect(false).toNot(beTrue() && beFalse())
        await expect(true).toNot(beTruthy() && beFalsy())
    }

    #if !os(WASI)
    @available(macOS 13.0.0, iOS 16.0.0, tvOS 16.0.0, watchOS 9.0.0, *)
    func testAsyncSatisfyAllOfCachesExpressionBeforePassingToMatchers() async {
        // This is not a great example of assertion writing - functions being asserted on in Expressions should not have side effects.
        // But we should still handle those cases anyway.
        actor Counter {
            var value: Int = 0
            func increment() -> Int {
                value += 1
                return value
            }
        }

        let counter = Counter()

        await expecta(await counter.increment()).toEventually(satisfyAllOf(asyncEqual(1), asyncEqual(1)))
    }
    #endif // !os(WASI)
    #endif // swift(>=5.8.0)
}
