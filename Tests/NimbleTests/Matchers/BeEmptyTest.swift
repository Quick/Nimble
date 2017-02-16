import Foundation
import XCTest
import Nimble

final class BeEmptyTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeEmptyTest) -> () throws -> Void)] {
        return [
            ("testBeEmptyPositive", testBeEmptyPositive),
            ("testBeEmptyNegative", testBeEmptyNegative),
        ]
    }

    func testBeEmptyPositive() {
        expect([] as [Int]).to(beEmpty())
        expect([1]).toNot(beEmpty())

        expect([] as [CInt]).to(beEmpty())
        expect([1] as [CInt]).toNot(beEmpty())

#if _runtime(_ObjC)
        expect(NSDictionary() as? [Int:Int]).to(beEmpty())
        expect(NSDictionary(object: 1, forKey: 1 as NSNumber) as? [Int:Int]).toNot(beEmpty())
#endif

        expect([Int: Int]()).to(beEmpty())
        expect(["hi": 1]).toNot(beEmpty())

#if _runtime(_ObjC)
        expect(NSArray() as? [Int]).to(beEmpty())
        expect(NSArray(array: [1]) as? [Int]).toNot(beEmpty())
#endif

        expect(NSSet()).to(beEmpty())
        expect(NSSet(array: [NSNumber(value: 1)])).toNot(beEmpty())

        expect(NSIndexSet()).to(beEmpty())
        expect(NSIndexSet(index: 1)).toNot(beEmpty())

        expect(NSString()).to(beEmpty())
        expect(NSString(string: "hello")).toNot(beEmpty())

        expect("").to(beEmpty())
        expect("foo").toNot(beEmpty())
    }

    func testBeEmptyNegative() {
        failsWithErrorMessageForNil("expected to be empty, got <nil>") {
            expect(nil as NSString?).to(beEmpty())
        }
        failsWithErrorMessageForNil("expected to not be empty, got <nil>") {
            expect(nil as [CInt]?).toNot(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <()>") {
            expect(NSArray()).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <[1]>") {
            expect([1]).to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <{()}>") {
            expect(NSSet()).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <{(1)}>") {
            expect(NSSet(object: NSNumber(value: 1))).to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <()>") {
            expect(NSIndexSet()).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <(1)>") {
            expect(NSIndexSet(index: 1)).to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <>") {
            expect("").toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <foo>") {
            expect("foo").to(beEmpty())
        }
    }
}
