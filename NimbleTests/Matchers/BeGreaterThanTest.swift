import XCTest
import Nimble

class BeGreaterThanTest: XCTestCase {
    func testGreaterThan() {
        expect(10).to(beGreaterThan(2))
        expect(1).toNot(beGreaterThan(2))
        expect(NSNumber.numberWithInt(3)).to(beGreaterThan(2))
        expect(NSNumber.numberWithInt(1)).toNot(beGreaterThan(NSNumber.numberWithInt(2)))

        failsWithErrorMessage("expected <0> to be greater than <2>") {
            expect(0).to(beGreaterThan(2))
            return
        }
        failsWithErrorMessage("expected <1> to not be greater than <0>") {
            expect(1).toNot(beGreaterThan(0))
            return
        }
    }

    func testGreaterThanOperator() {
        expect(1) > 0
        expect(NSNumber.numberWithInt(1)) > NSNumber.numberWithInt(0)
        expect(NSNumber.numberWithInt(1)) > 0

        failsWithErrorMessage("expected <1> to be greater than <2>") {
            expect(1) > 2
            return
        }
    }
}
