import XCTest
import Nimble

class BeCloseToTest: XCTestCase {
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

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1.0000), got <1.2000>") {
            expect(NSNumber(double:1.2)).toNot(beCloseTo(1.2001, within: 1.0))
        }
    }
    
    func testBeCloseToOperator() {
        expect(1.2) ~= 1.2001
        expect(1.2 as CDouble) ~= 1.2001
        
        failsWithErrorMessage("expected to be close to <1.2002> (within 0.0001), got <1.2000>") {
            expect(1.2) ~= 1.2002
        }
    }

    func testBeCloseToWithinOperator() {
        expect(1.2) ~= (9.300, 10)
        
        failsWithErrorMessage("expected to be close to <1.0000> (within 0.1000), got <1.2000>") {
            expect(1.2) ~= (1.0, 0.1)
        }
    }
    
}
