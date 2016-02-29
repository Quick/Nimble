import XCTest
import Nimble

#if _runtime(_ObjC)

class TestNull : NSNull {}

class BeAKindOfTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testPositiveMatch", testPositiveMatch),
            ("testFailureMessages", testFailureMessages),
            ("testSwiftTypesFailureMessages", testSwiftTypesFailureMessages),
        ]
    }

    func testPositiveMatch() {
        expect(TestNull()).to(beAKindOf(NSNull))
        expect(NSObject()).to(beAKindOf(NSObject))
        expect(NSNumber(integer:1)).toNot(beAKindOf(NSDate))
    }

    func testFailureMessages() {
        failsWithErrorMessageForNil("expected to not be a kind of NSNull, got <nil>") {
            expect(nil as NSNull?).toNot(beAKindOf(NSNull))
        }
        failsWithErrorMessageForNil("expected to be a kind of NSString, got <nil>") {
            expect(nil as NSString?).to(beAKindOf(NSString))
        }
        failsWithErrorMessage("expected to be a kind of NSString, got <__NSCFNumber instance>") {
            expect(NSNumber(integer:1)).to(beAKindOf(NSString))
        }
        failsWithErrorMessage("expected to not be a kind of NSNumber, got <__NSCFNumber instance>") {
            expect(NSNumber(integer:1)).toNot(beAKindOf(NSNumber))
        }
    }
    
    func testSwiftTypesFailureMessages() {
        enum TestEnum {
            case One, Two
        }
        failsWithErrorMessage("beAKindOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(1).to(beAKindOf(Int))
        }
        failsWithErrorMessage("beAKindOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect("test").to(beAKindOf(String))
        }
        failsWithErrorMessage("beAKindOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(TestEnum.One).to(beAKindOf(TestEnum))
        }
    }
}
#endif
