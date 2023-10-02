import Nimble
import XCTest
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

func asyncEqual<T: Equatable>(_ expectedValue: T) -> AsyncMatcher<T> {
    AsyncMatcher.define { expression in
        let message = ExpectationMessage.expectedActualValueTo("equal \(expectedValue)")
        if let value = try await expression.evaluate() {
            return MatcherResult(bool: value == expectedValue, message: message)
        } else {
            return MatcherResult(status: .fail, message: message.appendedBeNilHint())
        }
    }
}

func asyncContain<S: Sequence>(_ items: S.Element...) -> AsyncMatcher<S> where S.Element: Equatable {
    return asyncContain(items)
}

func asyncContain<S: Sequence>(_ items: [S.Element]) -> AsyncMatcher<S> where S.Element: Equatable {
    return AsyncMatcher.simple("contain <\(String(describing: items))>") { actualExpression in
        guard let actual = try await actualExpression.evaluate() else { return .fail }

        let matches = items.allSatisfy {
            return actual.contains($0)
        }
        return MatcherStatus(bool: matches)
    }
}

func asyncBeCloseTo<Value: FloatingPoint>(
    _ expectedValue: Value
) -> AsyncMatcher<Value> {
    let delta: Value = 1/10000
    let errorMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    return AsyncMatcher.simple(errorMessage) { actualExpression in
        guard let actualValue = try await actualExpression.evaluate() else {
            return .doesNotMatch
        }

        return MatcherStatus(bool: abs(actualValue - expectedValue) < delta)
    }
}

func asyncEqualityCheck<T: Equatable>(_ received: T, _ expected: T) async -> Bool {
    received == expected
}

final class AsyncMatchersTest: XCTestCase {
    func testAsyncEqual() async {
        await expect(1).to(asyncEqual(1))
        await expect(2).toNot(asyncEqual(1))

        await failsWithErrorMessage("expected to equal 1, got 2") {
            await expect(2).to(asyncEqual(1))
        }
    }

    func testAsyncContain() async {
        await expect([1, 2, 3]).to(asyncContain(1))

        await expect([1, 2, 3]).to(asyncContain(1, 2))
        await expect([1, 2, 3]).to(asyncContain([1, 2]))

        await expect([1, 2, 3]).to(asyncContain(2, 1))
        await expect([1, 2, 3]).to(asyncContain([2, 1]))

        await expect([1, 2, 3]).toNot(asyncContain(4))

        await expect([1, 2, 3]).toNot(asyncContain(4, 2))
        await expect([1, 2, 3]).toNot(asyncContain([4, 2]))

        await expect([1, 2, 3]).toNot(asyncContain(2, 4))
        await expect([1, 2, 3]).toNot(asyncContain([2, 4]))
    }

    func testAsyncBeCloseTo() async {
        await expect(1.2).to(asyncBeCloseTo(1.2001))
        await expect(1.2 as CDouble).to(asyncBeCloseTo(1.2001))
        await expect(1.2 as Float).to(asyncBeCloseTo(1.2001))

        await failsWithErrorMessage("expected to not be close to <1.2001> (within 0.0001), got <1.2>") {
            await expect(1.2).toNot(asyncBeCloseTo(1.2001))
        }
    }
}
