import XCTest
import Nimble

final class BePresentTest: XCTestCase {
    
    func producesPresent() -> [Int]? {
        [1,2,3]
    }
    
    func testBePresent() {
        expect(1 as Int?).to(bePresent())
        expect(nil as Int?).toNot(bePresent())
        expect(self.producesPresent()).to(bePresent())
        
        failsWithErrorMessage("expected to not be present, got <1>") {
            expect(1 as Int?).toNot(bePresent())
        }
        
        failsWithErrorMessage("expected to be present, got <nil>") {
            expect(nil as Int?).to(bePresent())
        }
    }
}
