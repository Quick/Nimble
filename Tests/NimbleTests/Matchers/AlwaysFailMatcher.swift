import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

func alwaysFail<T>() -> Nimble.Matcher<T> {
    return Matcher { _ throws -> MatcherResult in
        return MatcherResult(status: .fail, message: .fail("This matcher should always fail"))
    }
}

func asyncAlwaysFail<T>() -> AsyncMatcher<T> {
    return AsyncMatcher { _ throws -> MatcherResult in
        return MatcherResult(status: .fail, message: .fail("This matcher should always fail"))
    }
}

final class AlwaysFailTest: XCTestCase {
    func testAlwaysFail() {
        failsWithErrorMessage(
            "This matcher should always fail") {
            expect(true).toNot(alwaysFail())
        }

        failsWithErrorMessage(
            "This matcher should always fail") {
            expect(true).to(alwaysFail())
        }
    }

    func testAsyncAlwaysFail() async {
        await failsWithErrorMessage(
            "This matcher should always fail") {
            await expect(true).toNot(asyncAlwaysFail())
        }

        await failsWithErrorMessage(
            "This matcher should always fail") {
            await expect(true).to(asyncAlwaysFail())
        }
    }
}
