import XCTest
import Kick

class TestNull : NSNull {}

class BeASubclassOfTest: XCTestCase {
    func testPositiveMatch() {
        expect(nil as NSNull?).toNot(beASubclassOf(NSNull))

        expect(TestNull()).to(beASubclassOf(NSNull))
        expect(NSNumber.numberWithInteger(1)).toNot(beASubclassOf(NSDate))
    }

    func testFailureMessages() {
        failsWithErrorMessage("expected <nil> to be a subclass of NSString") {
            expect(nil as NSString?).to(beASubclassOf(NSString))
        }
        failsWithErrorMessage("expected <__NSCFNumber instance> to be a subclass of NSString") {
            expect(NSNumber.numberWithInteger(1)).to(beASubclassOf(NSString))
        }
        failsWithErrorMessage("expected <__NSCFNumber instance> to not be a subclass of NSNumber") {
            expect(NSNumber.numberWithInteger(1)).toNot(beASubclassOf(NSNumber))
        }
    }
}
