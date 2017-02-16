import Foundation
import XCTest
import Nimble

fileprivate protocol TestProtocol {}
fileprivate class TestClassConformingToProtocol: TestProtocol {}
fileprivate struct TestStructConformingToProtocol: TestProtocol {}

final class BeAnInstanceOfTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeAnInstanceOfTest) -> () throws -> Void)] {
        return [
            ("testPositiveMatch", testPositiveMatch),
            ("testPositiveMatchSwiftTypes", testPositiveMatchSwiftTypes),
            ("testFailureMessages", testFailureMessages),
            ("testFailureMessagesSwiftTypes", testFailureMessagesSwiftTypes),
        ]
    }

    func testPositiveMatch() {
        expect(NSNull()).to(beAnInstanceOf(NSNull.self))
        expect(NSNumber(value:1)).toNot(beAnInstanceOf(NSDate.self))
    }

    enum TestEnum {
        case one, two
    }

    func testPositiveMatchSwiftTypes() {
        expect(1).to(beAnInstanceOf(Int.self))
        expect("test").to(beAnInstanceOf(String.self))

        expect(TestEnum.one).to(beAnInstanceOf(TestEnum.self))

        let testProtocolClass = TestClassConformingToProtocol()
        expect(testProtocolClass).to(beAnInstanceOf(TestClassConformingToProtocol.self))
        expect(testProtocolClass).toNot(beAnInstanceOf(TestProtocol.self))
        expect(testProtocolClass).toNot(beAnInstanceOf(TestStructConformingToProtocol.self))

        let testProtocolStruct = TestStructConformingToProtocol()
        expect(testProtocolStruct).to(beAnInstanceOf(TestStructConformingToProtocol.self))
        expect(testProtocolStruct).toNot(beAnInstanceOf(TestProtocol.self))
        expect(testProtocolStruct).toNot(beAnInstanceOf(TestClassConformingToProtocol.self))
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

    func testFailureMessagesSwiftTypes() {
        failsWithErrorMessage("expected to not be an instance of Int, got <Int instance>") {
            expect(1).toNot(beAnInstanceOf(Int.self))
        }

        let testClass = TestClassConformingToProtocol()
        failsWithErrorMessage("expected to be an instance of \(String(describing: TestProtocol.self)), got <\(String(describing: TestClassConformingToProtocol.self)) instance>") {
            expect(testClass).to(beAnInstanceOf(TestProtocol.self))
        }

        failsWithErrorMessage("expected to be an instance of String, got <Int instance>") {
            expect(1).to(beAnInstanceOf(String.self))
        }
    }
}
