import Foundation
import XCTest
@testable import Nimble

class BeIdenticalToTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testBeIdenticalToPositive", testBeIdenticalToPositive),
            ("testBeIdenticalToNegative", testBeIdenticalToNegative),
            ("testBeIdenticalToPositiveMessage", testBeIdenticalToPositiveMessage),
            ("testBeIdenticalToNegativeMessage", testBeIdenticalToNegativeMessage),
            ("testOperators", testOperators),
            ("testBeAlias", testBeAlias)
        ]
    }

    func testBeIdenticalToPositive() {
        let value = NSDate()
        expect(value).to(beIdenticalTo(value))
    }

    func testBeIdenticalToNegative() {
        expect(NSNumber(integer:1)).toNot(beIdenticalTo(NSString(string: "yo")))
        expect(NSArray(array: [NSNumber(integer: 1)])).toNot(beIdenticalTo(NSArray(array: [NSNumber(integer: 1)])))
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
        let value = NSDate()
        expect(value) === value
        expect(NSNumber(integer:1)) !== NSNumber(integer:2)
    }

    func testBeAlias() {
        let value = NSDate()
        expect(value).to(be(value))
        expect(NSNumber(integer:1)).toNot(be(NSString(stringLiteral: "turtles")))
        #if _runtime(_ObjC)
            expect([1]).toNot(be([1]))
        #else
            expect(NSArray(array: [NSNumber(integer: 1)])).toNot(beIdenticalTo(NSArray(array: [NSNumber(integer: 1)])))
        #endif

        let value1 = NSArray(array: [])
        let value2 = NSArray(array: [])
        let message = "expected to not be identical to \(identityAsString(value2)), got \(identityAsString(value1))"
        failsWithErrorMessage(message) {
            expect(value1).toNot(be(value2))
        }
    }
}
