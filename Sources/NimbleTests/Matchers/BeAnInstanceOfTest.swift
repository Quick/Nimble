import Foundation
import XCTest
import Nimble

class BeAnInstanceOfTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testPositiveMatch", testPositiveMatch),
            ("testFailureMessages", testFailureMessages),
            ("testSwiftTypesFailureMessages", testSwiftTypesFailureMessages),
        ]
    }

    func testPositiveMatch() {
        expect(NSNull()).to(beAnInstanceOf(NSNull))
        expect(NSNumber(integer:1)).toNot(beAnInstanceOf(NSDate))
    }

    func testFailureMessages() {
        failsWithErrorMessageForNil("expected to not be an instance of NSNull, got <nil>") {
            expect(nil as NSNull?).toNot(beAnInstanceOf(NSNull))
        }
        failsWithErrorMessageForNil("expected to be an instance of NSString, got <nil>") {
            expect(nil as NSString?).to(beAnInstanceOf(NSString))
        }
#if _runtime(_ObjC)
        let numberTypeName = "__NSCFNumber"
#else
        let numberTypeName = "NSNumber"
#endif
        failsWithErrorMessage("expected to be an instance of NSString, got <\(numberTypeName) instance>") {
            expect(NSNumber(integer:1)).to(beAnInstanceOf(NSString))
        }
        failsWithErrorMessage("expected to not be an instance of NSNumber, got <\(numberTypeName) instance>") {
            expect(NSNumber(integer:1)).toNot(beAnInstanceOf(NSNumber))
        }
    }
    
    func testSwiftTypesFailureMessages() {
        enum TestEnum {
            case One, Two
        }

        failsWithErrorMessage("beAnInstanceOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(1).to(beAnInstanceOf(Int))
        }
        failsWithErrorMessage("beAnInstanceOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect("test").to(beAnInstanceOf(String))
        }
        failsWithErrorMessage("beAnInstanceOf only works on Objective-C types since the Swift compiler"
            + " will automatically type check Swift-only types. This expectation is redundant.") {
            expect(TestEnum.One).to(beAnInstanceOf(TestEnum))
        }
    }
    
}
