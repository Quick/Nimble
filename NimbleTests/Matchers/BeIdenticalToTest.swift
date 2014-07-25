import XCTest
import Nimble

class BeIdenticalToTest: XCTestCase {
    func testBeIdenticalToPositive() {
        expect(NSNumber.numberWithInteger(1)).to(beIdenticalTo(NSNumber.numberWithInteger(1)))
    }

    func testBeIdenticalToNegative() {
        expect(NSNumber.numberWithInteger(1)).toNot(beIdenticalTo("yo"))
        expect([1]).toNot(beIdenticalTo([1]))
    }

    func testBeIdenticalToPositiveMessage() {
        let num1 = NSNumber.numberWithInteger(1)
        let num2 = NSNumber.numberWithInteger(2)
        let message = NSString(format: "expected <%p> to be identical to <%p>", num1, num2)
        failsWithErrorMessage(message) {
            expect(num1).to(beIdenticalTo(num2))
        }
    }

    func testBeIdenticalToNegativeMessage() {
        let value1 = NSArray(array: [])
        let value2 = NSArray(array: [])
        let message = NSString(format: "expected <%p> to not be identical to <%p>", value1, value2)
        failsWithErrorMessage(message) {
            expect(value1).toNot(beIdenticalTo(value2))
        }
    }

    func testOperators() {
        expect(NSNumber.numberWithInteger(1)) === NSNumber.numberWithInteger(1)
        expect(NSNumber.numberWithInteger(1)) !== NSNumber.numberWithInteger(2)
    }
}
