import Foundation
import XCTest
import Nimble

class BeIdenticalToTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () -> Void)] {
        return [
            ("testBeIdenticalToPositive", testBeIdenticalToPositive),
            ("testBeIdenticalToNegative", testBeIdenticalToNegative),
            ("testBeIdenticalToPositiveMessage", testBeIdenticalToPositiveMessage),
            ("testBeIdenticalToNegativeMessage", testBeIdenticalToNegativeMessage),
            ("testOperators", testOperators),
        ]
    }

    func testBeIdenticalToPositive() {
        let value = NSDate()
        expect(value).to(beIdenticalTo(value))
    }

    func testBeIdenticalToNegative() {
        expect(NSNumber(integer:1)).toNot(beIdenticalTo("yo"))
        expect([1]).toNot(beIdenticalTo([1]))
    }

    func testBeIdenticalToPositiveMessage() {
        let num1 = NSNumber(integer:1)
        let num2 = NSNumber(integer:2)
        let message = NSString(format: "expected to be identical to <%p>, got <%p>", num2, num1)
        failsWithErrorMessage(message.description) {
            expect(num1).to(beIdenticalTo(num2))
        }
    }

    func testBeIdenticalToNegativeMessage() {
        let value1 = NSArray(array: [])
        let value2 = NSArray(array: [])
        let message = NSString(format: "expected to not be identical to <%p>, got <%p>", value2, value1)
        failsWithErrorMessage(message.description) {
            expect(value1).toNot(beIdenticalTo(value2))
        }
    }
    
    func testOperators() {
        let value = NSDate()
        expect(value) === value
        expect(NSNumber(integer:1)) !== NSNumber(integer:2)
    }
}
