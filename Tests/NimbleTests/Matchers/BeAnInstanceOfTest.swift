import Foundation
import XCTest
import Nimble

final class BeAnInstanceOfTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeAnInstanceOfTest) -> () throws -> Void)] {
        return [
            ("testPositiveMatch", testPositiveMatch),
            ("testFailureMessages", testFailureMessages),
            ("testSwiftTypesFailureMessages", testSwiftTypesFailureMessages),
        ]
    }

    func testPositiveMatch() {
        expect(NSNull()).to(beAnInstanceOf(NSNull.self))
        expect(NSNumber(value:1)).toNot(beAnInstanceOf(NSDate.self))
    }

    func testFailureMessages() {
        failsWithErrorMessageForNil("expected to not be an instance of NSNull, got <nil>") {
            expect(nil as NSNull?).toNot(beAnInstanceOf(NSNull.self))
        }
        failsWithErrorMessageForNil("expected to be an instance of NSString, got <nil>") {
            expect(nil as NSString?).to(beAnInstanceOf(NSString.self))
        }
#if _runtime(_ObjC)
        let numberTypeName = "__NSCFNumber"
#else
        let numberTypeName = "NSNumber"
#endif
        failsWithErrorMessage("expected to be an instance of NSString, got <\(numberTypeName) instance>") {
            expect(NSNumber(value:1)).to(beAnInstanceOf(NSString.self))
        }
        failsWithErrorMessage("expected to not be an instance of NSNumber, got <\(numberTypeName) instance>") {
            expect(NSNumber(value:1)).toNot(beAnInstanceOf(NSNumber.self))
        }
    }
    
    func testSwiftTypesFailureMessages() {
        enum TestEnum {
            case one, two
        }

        failsWithErrorMessage("beAnInstanceOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(1).to(beAnInstanceOf(Int.self))
        }
        failsWithErrorMessage("beAnInstanceOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect("test").to(beAnInstanceOf(String.self))
        }
        failsWithErrorMessage("beAnInstanceOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(TestEnum.one).to(beAnInstanceOf(TestEnum.self))
        }
    }
    
}
