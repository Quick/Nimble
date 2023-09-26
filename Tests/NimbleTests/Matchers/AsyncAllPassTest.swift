import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

private func asyncCheck(_ closure: () -> Bool) async -> Bool {
    closure()
}

private func asyncBeLessThan<T: Comparable>(_ expectedValue: T?) -> AsyncMatcher<T> {
    let message = "be less than <\(stringify(expectedValue))>"
    return AsyncMatcher.simple(message) { actualExpression in
        guard let actual = try await actualExpression.evaluate(), let expected = expectedValue else { return .fail }

        return MatcherStatus(bool: actual < expected)
    }
}

private func asyncBeGreaterThan<T: Comparable>(_ expectedValue: T?) -> AsyncMatcher<T> {
    let message = "be greater than <\(stringify(expectedValue))>"
    return AsyncMatcher.simple(message) { actualExpression in
        guard let actual = try await actualExpression.evaluate(), let expected = expectedValue else { return .fail }

        return MatcherStatus(bool: actual > expected)
    }
}

private func asyncBeNil<T>() -> AsyncMatcher<T> {
    return AsyncMatcher.simpleNilable("be nil") { actualExpression in
        let actualValue = try await actualExpression.evaluate()
        return MatcherStatus(bool: actualValue == nil)
    }
}

final class AsyncAllPassTest: XCTestCase {
    func testAllPassArray() async {
        await expect([1, 2, 3, 4]).to(allPass { value in
            await asyncCheck { value < 5 }
        })
        await expect([1, 2, 3, 4]).toNot(allPass { value in
            await asyncCheck { value > 5 }
        })

        await failsWithErrorMessage(
            "expected to all pass a condition, but failed first at element <3> in <[1, 2, 3, 4]>") {
                await expect([1, 2, 3, 4]).to(allPass { value in
                    await asyncCheck { value < 3 }

                })
        }
        await failsWithErrorMessage("expected to not all pass a condition") {
            await expect([1, 2, 3, 4]).toNot(allPass { value in
                await asyncCheck { value < 5 }

            })
        }
        await failsWithErrorMessage(
            "expected to all be something, but failed first at element <3> in <[1, 2, 3, 4]>") {
                await expect([1, 2, 3, 4]).to(allPass("be something", { value in
                    await asyncCheck { value < 3 }
                }))
        }
        await failsWithErrorMessage("expected to not all be something") {
            await expect([1, 2, 3, 4]).toNot(allPass("be something", { value in
                await asyncCheck { value < 5 }
            }))
        }
    }

    func testAllPassMatcher() async {
        await expect([1, 2, 3, 4]).to(allPass(asyncBeLessThan(5)))
        await expect([1, 2, 3, 4]).toNot(allPass(asyncBeGreaterThan(5)))

        await failsWithErrorMessage(
            "expected to all be less than <3>, but failed first at element <3> in <[1, 2, 3, 4]>") {
                await expect([1, 2, 3, 4]).to(allPass(asyncBeLessThan(3)))
        }
        await failsWithErrorMessage("expected to not all be less than <5>") {
            await expect([1, 2, 3, 4]).toNot(allPass(asyncBeLessThan(5)))
        }
    }

    func testAllPassCollectionsWithOptionals() async {
        await expect([nil, nil, nil] as [Int?]).to(allPass(asyncBeNil()))
        await expect([nil, nil, nil] as [Int?]).to(allPass { value in
            await asyncCheck { value == nil }
        })
        await expect([nil, 1, nil] as [Int?]).toNot(allPass { value in
            await asyncCheck { value == nil }
        })
        await expect([1, 1, 1] as [Int?]).to(allPass { value in
            await asyncCheck { value == 1 }
        })
        await expect([1, 1, nil] as [Int?]).toNot(allPass { value in
            await asyncCheck { value == 1 }
        })
        await expect([1, 2, 3] as [Int?]).to(allPass { value in
            await asyncCheck { value < 4 }
        })
        await expect([1, 2, 3] as [Int?]).toNot(allPass { value in
            await asyncCheck { value < 3 }
        })
        await expect([1, 2, nil] as [Int?]).to(allPass { value in
            await asyncCheck { value < 3 }
        })
    }

    func testAllPassSet() async {
        await expect(Set([1, 2, 3, 4])).to(allPass { value in
            await asyncCheck {value < 5 }
        })
        await expect(Set([1, 2, 3, 4])).toNot(allPass { value in
            await asyncCheck {value > 5 }
        })

        await failsWithErrorMessage("expected to not all pass a condition") {
            await expect(Set([1, 2, 3, 4])).toNot(allPass { value in
                await asyncCheck {value < 5 }
            })
        }
        await failsWithErrorMessage("expected to not all be something") {
            await expect(Set([1, 2, 3, 4])).toNot(allPass("be something") { value in
                await asyncCheck {value < 5 }
            })
        }
    }

    func testAllPassWithNilAsExpectedValue() async {
        await failsWithErrorMessageForNil("expected to all pass") {
            await expect(nil as [Int]?).to(allPass(asyncBeLessThan(5)))
        }
    }
}
