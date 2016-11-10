import Foundation
import XCTest
import Nimble

protocol InstanceOfTestProtocol {}
class InstanceOfTestClassConformingToProtocol: InstanceOfTestProtocol{}
struct InstanceOfTestStructConformingToProtocol: InstanceOfTestProtocol{}

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

    func testPositiveMatchSwiftTypes() {
        expect(1).to(beAnInstanceOf(Int.self))
        expect("test").to(beAnInstanceOf(String.self))

        enum TestEnum {
            case one, two
        }

        expect(TestEnum.one).to(beAnInstanceOf(TestEnum.self))

        let testProtocolClass = InstanceOfTestClassConformingToProtocol()
        expect(testProtocolClass).to(beAnInstanceOf(InstanceOfTestClassConformingToProtocol.self))
        expect(testProtocolClass).toNot(beAnInstanceOf(InstanceOfTestProtocol.self))
        expect(testProtocolClass).toNot(beAnInstanceOf(InstanceOfTestStructConformingToProtocol.self))

        let testProtocolStruct = InstanceOfTestStructConformingToProtocol()
        expect(testProtocolStruct).to(beAnInstanceOf(InstanceOfTestStructConformingToProtocol.self))
        expect(testProtocolStruct).toNot(beAnInstanceOf(InstanceOfTestProtocol.self))
        expect(testProtocolStruct).toNot(beAnInstanceOf(InstanceOfTestClassConformingToProtocol.self))
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

        let testClass = InstanceOfTestClassConformingToProtocol()
        failsWithErrorMessage("expected to be an instance of InstanceOfTestProtocol, got <InstanceOfTestClassConformingToProtocol instance>") {
            expect(testClass).to(beAnInstanceOf(InstanceOfTestProtocol.self))
        }

        failsWithErrorMessage("expected to be an instance of String, got <Int instance>") {
            expect(1).to(beAnInstanceOf(String.self))
        }
    }
}
