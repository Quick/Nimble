import Foundation
import XCTest
@testable import Nimble

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
        expect(NSNumber(integer:1)).to(beIdenticalTo(NSNumber(integer:1)))
    }

    func testBeIdenticalToNegative() {
        expect(NSNumber(integer:1)).toNot(beIdenticalTo("yo"))
        expect([1]).toNot(beIdenticalTo([1]))
    }

    func testBeIdenticalToPositiveMessage() {
        let num1 = NSNumber(integer:1)
        let num2 = NSNumber(integer:2)
        let message = "expected to be identical to \(identityAsString(num2)), got \(identityAsString(num1))"
        failsWithErrorMessage(message) {
            expect(num1).to(beIdenticalTo(num2))
        }
    }

    func testBeIdenticalToNegativeMessage() {
        let value1 = NSArray(array: [])
        let value2 = NSArray(array: [])
        let message = "expected to not be identical to \(identityAsString(value2)), got \(identityAsString(value1))"
        failsWithErrorMessage(message) {
            expect(value1).toNot(beIdenticalTo(value2))
        }
    }
    
    func testOperators() {
        expect(NSNumber(integer:1)) === NSNumber(integer:1)
        expect(NSNumber(integer:1)) !== NSNumber(integer:2)
    }
}
