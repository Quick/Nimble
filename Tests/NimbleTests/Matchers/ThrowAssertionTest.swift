import Foundation
import XCTest
import Nimble

#if _runtime(_ObjC) && !SWIFT_PACKAGE

final class ThrowAssertionTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (ThrowAssertionTest) -> () throws -> Void)] {
        return [
            ("testPositiveMatch", testPositiveMatch),
            ("testErrorThrown", testErrorThrown),
            ("testPostAssertionCodeNotRun", testPostAssertionCodeNotRun),
            ("testNegativeMatch", testNegativeMatch),
            ("testPositiveMessage", testPositiveMessage),
            ("testNegativeMessage", testNegativeMessage),
        ]
    }

    func testPositiveMatch() {
        expect { () -> Void in fatalError() }.to(throwAssertion())
    }

    func testErrorThrown() {
        expect { throw NSError(domain: "test", code: 0, userInfo: nil) }.toNot(throwAssertion())
    }

    func testPostAssertionCodeNotRun() {
        var reachedPoint1 = false
        var reachedPoint2 = false

        expect {
            reachedPoint1 = true
            precondition(false, "condition message")
            reachedPoint2 = true
        }.to(throwAssertion())

        expect(reachedPoint1) == true
        expect(reachedPoint2) == false
    }

    func testNegativeMatch() {
        var reachedPoint1 = false

        expect { reachedPoint1 = true }.toNot(throwAssertion())

        expect(reachedPoint1) == true
    }

    func testPositiveMessage() {
        failsWithErrorMessage("expected to throw an assertion") {
            expect { () -> Void? in return }.to(throwAssertion())
        }
    }

    func testNegativeMessage() {
        failsWithErrorMessage("expected to not throw an assertion") {
            expect { () -> Void in fatalError() }.toNot(throwAssertion())
        }
    }
}

#endif
