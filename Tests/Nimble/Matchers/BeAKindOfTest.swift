import XCTest
import Nimble

#if _runtime(_ObjC)

class TestNull : NSNull {}

final class BeAKindOfTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeAKindOfTest) -> () throws -> Void)] {
        return [
            ("testPositiveMatch", testPositiveMatch),
            ("testFailureMessages", testFailureMessages),
            ("testSwiftTypesFailureMessages", testSwiftTypesFailureMessages),
        ]
    }

    func testPositiveMatch() {
        expect(TestNull()).to(beAKindOf(NSNull.self))
        expect(NSObject()).to(beAKindOf(NSObject.self))
        expect(NSNumber(value:1)).toNot(beAKindOf(NSDate.self))
    }

    func testFailureMessages() {
        failsWithErrorMessageForNil("expected to not be a kind of NSNull, got <nil>") {
            expect(nil as NSNull?).toNot(beAKindOf(NSNull.self))
        }
        failsWithErrorMessageForNil("expected to be a kind of NSString, got <nil>") {
            expect(nil as NSString?).to(beAKindOf(NSString.self))
        }
        failsWithErrorMessage("expected to be a kind of NSString, got <__NSCFNumber instance>") {
            expect(NSNumber(value:1)).to(beAKindOf(NSString.self))
        }
        failsWithErrorMessage("expected to not be a kind of NSNumber, got <__NSCFNumber instance>") {
            expect(NSNumber(value:1)).toNot(beAKindOf(NSNumber.self))
        }
    }
    
    func testSwiftTypesFailureMessages() {
        enum TestEnum {
            case one, two
        }
        failsWithErrorMessage("beAKindOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(1).to(beAKindOf(Int.self))
        }
        failsWithErrorMessage("beAKindOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect("test").to(beAKindOf(String.self))
        }
        failsWithErrorMessage("beAKindOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(TestEnum.one).to(beAKindOf(TestEnum.self))
        }
    }
}
#endif
