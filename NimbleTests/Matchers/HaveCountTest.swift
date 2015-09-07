import XCTest
import Nimble

class HaveCountTest: XCTestCase {
    func testEquality() {
        expect([1, 2, 3]).to(haveCount(3))
        expect([1, 2, 3]).notTo(haveCount(1))
    }
}