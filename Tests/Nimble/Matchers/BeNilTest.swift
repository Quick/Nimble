import XCTest
import Nimble

class BeNilTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testBeNil", testBeNil),
            ("testBeNilWithEqualityOperator", testBeNilWithEqualityOperator)
        ]
    }

    func producesNil() -> Array<Int>? {
        return nil
    }

    func testBeNil() {
        expect(nil as Int?).to(beNil())
        expect(1 as Int?).toNot(beNil())
        expect(self.producesNil()).to(beNil())

        failsWithErrorMessage("expected to not be nil, got <nil>") {
            expect(nil as Int?).toNot(beNil())
        }

        failsWithErrorMessage("expected to be nil, got <1>") {
            expect(1 as Int?).to(beNil())
        }
    }
    
    func testBeNilWithEqualityOperator() {
        expect(nil as Float?) == Nil
        expect(20 as Int?) != Nil
        expect(self.producesNil()) == Nil
        
        failsWithErrorMessage("expected to not be nil, got <nil>") {
            expect(nil as String?) != Nil
        }
        
        failsWithErrorMessage("expected to be nil, got <-99999>") {
            expect(-99999 as Int?) == Nil
        }
    }
}
