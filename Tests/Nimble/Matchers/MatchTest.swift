import XCTest
import Nimble

#if _runtime(_ObjC)

class MatchTest:XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testMatchPositive", testMatchPositive),
            ("testMatchNegative", testMatchNegative),
            ("testMatchPositiveMessage", testMatchPositiveMessage),
            ("testMatchNegativeMessage", testMatchNegativeMessage),
            ("testMatchNils", testMatchNils),
        ]
    }

    func testMatchPositive() {
        expect("11:14").to(match("\\d{2}:\\d{2}"))
    }
    
    func testMatchNegative() {
        expect("hello").toNot(match("\\d{2}:\\d{2}"))
    }
    
    func testMatchPositiveMessage() {
        let message = "expected to match <\\d{2}:\\d{2}>, got <hello>"
        failsWithErrorMessage(message) {
            expect("hello").to(match("\\d{2}:\\d{2}"))
        }
    }
    
    func testMatchNegativeMessage() {
        let message = "expected to not match <\\d{2}:\\d{2}>, got <11:14>"
        failsWithErrorMessage(message) {
            expect("11:14").toNot(match("\\d{2}:\\d{2}"))
        }
    }

    func testMatchNils() {
        failsWithErrorMessageForNil("expected to match <\\d{2}:\\d{2}>, got <nil>") {
            expect(nil as String?).to(match("\\d{2}:\\d{2}"))
        }

        failsWithErrorMessageForNil("expected to not match <\\d{2}:\\d{2}>, got <nil>") {
            expect(nil as String?).toNot(match("\\d{2}:\\d{2}"))
        }
    }
}
#endif
