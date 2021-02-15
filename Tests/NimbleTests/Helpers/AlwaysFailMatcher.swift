import XCTest
import Nimble

func alwaysFail<T>() -> Predicate<T> {
    return Predicate { _ throws -> PredicateResult in
        return PredicateResult(status: .fail, message: .fail("This matcher should always fail"))
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
}
