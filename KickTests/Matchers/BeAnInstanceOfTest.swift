import XCTest
import Kick

class BeAnInstanceOfTest: XCTestCase {

    func testBeAnInstanceOfPositive() {
        expect(NSNumber.numberWithInteger(1)).to(beAnInstanceOf(NSNumber))
    }

    func testBeAnInstanceOfNegative() {
        expect(NSNumber.numberWithInteger(1)).toNot(beAnInstanceOf(NSString))
    }

    func testBeAnInstanceOfPositiveMessage() {
        failsWithErrorMessage("expected <1> to be an instance of NSString") {
            expect(NSNumber.numberWithInteger(1)).to(beAnInstanceOf(NSString))
        }
    }

    func testBeAnInstanceOfNegativeMessage() {
        failsWithErrorMessage("expected <1> to not be an instance of NSNumber") {
            expect(NSNumber.numberWithInteger(1)).toNot(beAnInstanceOf(NSNumber))
        }
    }
}
