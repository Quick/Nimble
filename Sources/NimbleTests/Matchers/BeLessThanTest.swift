import Foundation
import XCTest
import Nimble

class BeLessThanTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testLessThan", testLessThan),
            ("testLessThanOperator", testLessThanOperator),
        ]
    }

    func testLessThan() {
        expect(2).to(beLessThan(10))
        expect(2).toNot(beLessThan(1))
#if _runtime(_ObjC)
        expect(NSNumber(integer:2)).to(beLessThan(10))
        expect(NSNumber(integer:2)).toNot(beLessThan(1))

        expect(2).to(beLessThan(NSNumber(integer:10)))
        expect(2).toNot(beLessThan(NSNumber(integer:1)))
#endif

        failsWithErrorMessage("expected to be less than <0>, got <2>") {
            expect(2).to(beLessThan(0))
        }
        failsWithErrorMessage("expected to not be less than <1>, got <0>") {
            expect(0).toNot(beLessThan(1))
        }

        failsWithErrorMessageForNil("expected to be less than <2>, got <nil>") {
            expect(nil as Int?).to(beLessThan(2))
        }
        failsWithErrorMessageForNil("expected to not be less than <-1>, got <nil>") {
            expect(nil as Int?).toNot(beLessThan(-1))
        }
    }

    func testLessThanOperator() {
        expect(0) < 1
#if _runtime(_ObjC)
        expect(NSNumber(int:0)) < 1
#endif

#if _runtime(_ObjC)
        let (expectedRepresentation, actualRepresentation) = ("1.0000", "2.0000")
#else
        let (expectedRepresentation, actualRepresentation) = ("1", "2")
#endif
        failsWithErrorMessage("expected to be less than <\(expectedRepresentation)>, got <\(actualRepresentation)>") {
            expect(2) < 1
            return
        }
    }
}
