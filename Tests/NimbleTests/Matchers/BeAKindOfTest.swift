import XCTest
import Nimble

#if _runtime(_ObjC)

class KindOfTestNull : NSNull {}
protocol KindOfTestProtocol {}
class KindOfTestClassConformingToProtocol: KindOfTestProtocol{}
struct KindOfTestStructConformingToProtocol: KindOfTestProtocol{}

final class BeAKindOfTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeAKindOfTest) -> () throws -> Void)] {
        return [
            ("testPositiveMatch", testPositiveMatch),
            ("testPositiveMatchSwiftTypes", testPositiveMatchSwiftTypes),
            ("testFailureMessages", testFailureMessages),
            ("testFailureMessagesSwiftTypes", testFailureMessagesSwiftTypes)
        ]
    }

    func testPositiveMatch() {
        expect(KindOfTestNull()).to(beAKindOf(NSNull.self))
        expect(NSObject()).to(beAKindOf(NSObject.self))
        expect(NSNumber(value:1)).toNot(beAKindOf(NSDate.self))
    }

    func testPositiveMatchSwiftTypes() {
        expect(1).to(beAKindOf(Int.self))
        expect(1).toNot(beAKindOf(String.self))
        expect("turtle string").to(beAKindOf(String.self))
        expect("turtle string").toNot(beAKindOf(KindOfTestClassConformingToProtocol.self))

        enum TestEnum {
            case one, two
        }

        expect(TestEnum.one).to(beAKindOf(TestEnum.self))

        let testProtocolClass = KindOfTestClassConformingToProtocol()
        expect(testProtocolClass).to(beAKindOf(KindOfTestClassConformingToProtocol.self))
        expect(testProtocolClass).to(beAKindOf(KindOfTestProtocol.self))
        expect(testProtocolClass).toNot(beAKindOf(KindOfTestStructConformingToProtocol.self))

        let testProtocolStruct = KindOfTestStructConformingToProtocol()
        expect(testProtocolStruct).to(beAKindOf(KindOfTestStructConformingToProtocol.self))
        expect(testProtocolStruct).to(beAKindOf(KindOfTestProtocol.self))
        expect(testProtocolStruct).toNot(beAKindOf(KindOfTestClassConformingToProtocol.self))
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

    func testFailureMessagesSwiftTypes() {
        failsWithErrorMessage("expected to not be a kind of Int, got <Int instance>") {
            expect(1).toNot(beAKindOf(Int.self))
        }

        let testClass = KindOfTestClassConformingToProtocol()
        failsWithErrorMessage("expected to not be a kind of KindOfTestProtocol, got <KindOfTestClassConformingToProtocol instance>") {
            expect(testClass).toNot(beAKindOf(KindOfTestProtocol.self))
        }

        failsWithErrorMessage("expected to be a kind of String, got <Int instance>") {
            expect(1).to(beAKindOf(String.self))
        }
    }
}
#endif
