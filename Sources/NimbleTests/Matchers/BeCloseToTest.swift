import Foundation
import XCTest
import Nimble

class BeCloseToTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testBeCloseTo", testBeCloseTo),
            ("testBeCloseToWithin", testBeCloseToWithin),
            ("testBeCloseToWithNSNumber", testBeCloseToWithNSNumber),
            ("testBeCloseToWithNSDate", testBeCloseToWithNSDate),
            ("testBeCloseToOperator", testBeCloseToOperator),
            ("testBeCloseToWithinOperator", testBeCloseToWithinOperator),
            ("testPlusMinusOperator", testPlusMinusOperator),
            ("testBeCloseToArray", testBeCloseToArray),
        ]
    }

    func testBeCloseTo() {
        expect(1.2).to(beCloseTo(1.2001))
        expect(1.2 as CDouble).to(beCloseTo(1.2001))
        expect(1.2 as Float).to(beCloseTo(1.2001))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 0.0001), got <1.2000>") {
            expect(1.2).toNot(beCloseTo(1.2001))
        }
    }

    func testBeCloseToWithin() {
        expect(1.2).to(beCloseTo(9.300, within: 10))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1.0000), got <1.2000>") {
            expect(1.2).toNot(beCloseTo(1.2001, within: 1.0))
        }
    }

    func testBeCloseToWithNSNumber() {
        expect(NSNumber(double:1.2)).to(beCloseTo(9.300, within: 10))
        expect(NSNumber(double:1.2)).to(beCloseTo(NSNumber(double:9.300), within: 10))
        expect(1.2).to(beCloseTo(NSNumber(double:9.300), within: 10))

#if _runtime(_ObjC)
        let expectedRepresentation = "1.2000"
#else
        let expectedRepresentation = "1.2"
#endif
        failsWithErrorMessage("expected to not be close to <1.2001> (within 1.0000), got <\(expectedRepresentation)>") {
            expect(NSNumber(double:1.2)).toNot(beCloseTo(1.2001, within: 1.0))
        }
    }
    
    func testBeCloseToWithNSDate() {
#if _runtime(_ObjC) // NSDateFormatter isn't functional in swift-corelibs-foundation yet.
        expect(NSDate(dateTimeString: "2015-08-26 11:43:00")).to(beCloseTo(NSDate(dateTimeString: "2015-08-26 11:43:05"), within: 10))
        
        failsWithErrorMessage("expected to not be close to <2015-08-26 11:43:00.0050> (within 0.0040), got <2015-08-26 11:43:00.0000>") {

            let expectedDate = NSDate(dateTimeString: "2015-08-26 11:43:00").dateByAddingTimeInterval(0.005)
            expect(NSDate(dateTimeString: "2015-08-26 11:43:00")).toNot(beCloseTo(expectedDate, within: 0.004))
        }
#endif
    }
    
    func testBeCloseToOperator() {
        expect(1.2) ≈ 1.2001
        expect(1.2 as CDouble) ≈ 1.2001
        
        failsWithErrorMessage("expected to be close to <1.2002> (within 0.0001), got <1.2000>") {
            expect(1.2) ≈ 1.2002
        }
    }

    func testBeCloseToWithinOperator() {
        expect(1.2) ≈ (9.300, 10)
        expect(1.2) == (9.300, 10)
        
        failsWithErrorMessage("expected to be close to <1.0000> (within 0.1000), got <1.2000>") {
            expect(1.2) ≈ (1.0, 0.1)
        }
        failsWithErrorMessage("expected to be close to <1.0000> (within 0.1000), got <1.2000>") {
            expect(1.2) == (1.0, 0.1)
        }
    }
    
    func testPlusMinusOperator() {
        expect(1.2) ≈ 9.300 ± 10
        expect(1.2) == 9.300 ± 10
        
        failsWithErrorMessage("expected to be close to <1.0000> (within 0.1000), got <1.2000>") {
            expect(1.2) ≈ 1.0 ± 0.1
        }
        failsWithErrorMessage("expected to be close to <1.0000> (within 0.1000), got <1.2000>") {
            expect(1.2) == 1.0 ± 0.1
        }
    }

    func testBeCloseToArray() {
        expect([0.0, 1.1, 2.2]) ≈ [0.0001, 1.1001, 2.2001]
        expect([0.0, 1.1, 2.2]).to(beCloseTo([0.1, 1.2, 2.3], within: 0.1))
        
        failsWithErrorMessage("expected to be close to <[0.0000, 1.0000]> (each within 0.0001), got <[0.0000, 1.1000]>") {
            expect([0.0, 1.1]) ≈ [0.0, 1.0]
        }
        failsWithErrorMessage("expected to be close to <[0.2000, 1.2000]> (each within 0.1000), got <[0.0000, 1.1000]>") {
            expect([0.0, 1.1]).to(beCloseTo([0.2, 1.2], within: 0.1))
        }
    }
}
