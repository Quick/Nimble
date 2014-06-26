import XCTest
import Kick

class BeGreaterThanTest: XCTestCase {

    func testGreaterThan() {
        expect(1) > 0
        expect(10).to(beGreaterThan(2))
        expect(1).toNot(beGreaterThan(2))

        failsWithErrorMessage("expected <1> to be greater than <2>") {
            expect(1) > 2
            return
        }
        failsWithErrorMessage("expected <0> to be greater than <2>") {
            expect(0).to(beGreaterThan(2))
            return
        }
        failsWithErrorMessage("expected <1> to not be greater than <0>") {
            expect(1).toNot(beGreaterThan(0))
            return
        }
    }

}
