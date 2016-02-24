import Foundation
import XCTest
import Nimble

class BeGreaterThanTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testGreaterThan", testGreaterThan),
            ("testGreaterThanOperator", testGreaterThanOperator),
        ]
    }
    
    func testGreaterThan() {
        expect(10).to(beGreaterThan(2))
        expect(1).toNot(beGreaterThan(2))
#if _runtime(_ObjC)
        expect(NSNumber(int:3)).to(beGreaterThan(2))
#endif
        expect(NSNumber(int:1)).toNot(beGreaterThan(NSNumber(int:2)))

        failsWithErrorMessage("expected to be greater than <2>, got <0>") {
            expect(0).to(beGreaterThan(2))
        }
        failsWithErrorMessage("expected to not be greater than <0>, got <1>") {
            expect(1).toNot(beGreaterThan(0))
        }
        failsWithErrorMessageForNil("expected to be greater than <-2>, got <nil>") {
            expect(nil as Int?).to(beGreaterThan(-2))
        }
        failsWithErrorMessageForNil("expected to not be greater than <0>, got <nil>") {
            expect(nil as Int?).toNot(beGreaterThan(0))
        }
    }

    func testGreaterThanOperator() {
        expect(1) > 0
        expect(NSNumber(int:1)) > NSNumber(int:0)
#if _runtime(_ObjC)
        expect(NSNumber(int:1)) > 0
#endif

#if _runtime(_ObjC)
        let (expectedRepresentation, actualRepresentation) = ("2.0000", "1.0000")
#else
        let (expectedRepresentation, actualRepresentation) = ("2", "1")
#endif
        failsWithErrorMessage("expected to be greater than <\(expectedRepresentation)>, got <\(actualRepresentation)>") {
            expect(1) > 2
            return
        }
    }
}
