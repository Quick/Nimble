import XCTest
import Kick

class ExpectationTest: XCTestCase {
    func testTo() {
        expect(1).to(equal(1))
    }

    func testToNot() {
        expect(1).toNot(equal(2))
    }

    func testNotTo() {
        expect(1).notTo(equal(2))
    }
}
