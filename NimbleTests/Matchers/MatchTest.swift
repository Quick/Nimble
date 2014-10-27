import XCTest
import Nimble

class MatchTest:XCTestCase {
    func testMatchPositive() {
        expect("11:14").to(match("\\d{2}:\\d{2}"))
    }
    
    func testMatchNegative() {
        expect("hello").toNot(match("\\d{2}:\\d{2}"))
    }
    
    func testMatchPositiveMessage() {
        let message = "expected <hello> to match <\\d{2}:\\d{2}>"
        failsWithErrorMessage(message) {
            expect("hello").to(match("\\d{2}:\\d{2}"))
        }
    }
    
    func testMatchNegativeMessage() {
        let message = "expected <11:14> to not match <\\d{2}:\\d{2}>"
        failsWithErrorMessage(message) {
            expect("11:14").toNot(match("\\d{2}:\\d{2}"))
        }
    }
 
}