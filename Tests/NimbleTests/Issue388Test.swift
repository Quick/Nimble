import XCTest
import Nimble

final class Issue388Test: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (Issue388Test) -> () throws -> Void)] {
        return [
            ("testAllPassAndBeNil", testAllPassAndBeNil),
        ]
    }

    func testAllPassAndBeNil() {
        // FIXME: https://github.com/Quick/Nimble/issues/388
        failsWithErrorMessage("expected to all be nil, but failed first at element <nil> in <[nil, nil]>") {
            let a: Double? = nil
            let b: Double? = nil
            expect([a, b]).to(allPass(beNil()))
        }
    }
}
