import XCTest
import Nimble

class UserDescriptionTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testToMatcher_CustomFailureMessage", testToMatcher_CustomFailureMessage),
            ("testNotToMatcher_CustomFailureMessage", testNotToMatcher_CustomFailureMessage),
            ("testToNotMatcher_CustomFailureMessage", testToNotMatcher_CustomFailureMessage),
            ("testToEventuallyMatch_CustomFailureMessage", testToEventuallyMatch_CustomFailureMessage),
            ("testToEventuallyNotMatch_CustomFailureMessage", testToEventuallyNotMatch_CustomFailureMessage),
            ("testToNotEventuallyMatch_CustomFailureMessage", testToNotEventuallyMatch_CustomFailureMessage),
        ]
    }
    
    func testToMatcher_CustomFailureMessage() {
        failsWithErrorMessage(
            "These aren't equal!\n" +
            "expected to match, got <1>") {
                expect(1).to(MatcherFunc { expr, failure in false }, description: "These aren't equal!")
        }
    }
    
    func testNotToMatcher_CustomFailureMessage() {
        failsWithErrorMessage(
            "These aren't equal!\n" +
            "expected to not match, got <1>") {
                expect(1).notTo(MatcherFunc { expr, failure in true }, description: "These aren't equal!")
        }
    }
    
    func testToNotMatcher_CustomFailureMessage() {
        failsWithErrorMessage(
            "These aren't equal!\n" +
            "expected to not match, got <1>") {
                expect(1).toNot(MatcherFunc { expr, failure in true }, description: "These aren't equal!")
        }
    }
    
    func testToEventuallyMatch_CustomFailureMessage() {
#if _runtime(_ObjC)
        failsWithErrorMessage(
            "These aren't eventually equal!\n" +
            "expected to eventually equal <1>, got <0>") {
                expect { 0 }.toEventually(equal(1), description: "These aren't eventually equal!")
        }
#endif
    }
    
    func testToEventuallyNotMatch_CustomFailureMessage() {
#if _runtime(_ObjC)
        failsWithErrorMessage(
            "These are eventually equal!\n" +
            "expected to eventually not equal <1>, got <1>") {
                expect { 1 }.toEventuallyNot(equal(1), description: "These are eventually equal!")
        }
#endif
    }
    
    func testToNotEventuallyMatch_CustomFailureMessage() {
#if _runtime(_ObjC)
        failsWithErrorMessage(
            "These are eventually equal!\n" +
            "expected to eventually not equal <1>, got <1>") {
                expect { 1 }.toEventuallyNot(equal(1), description: "These are eventually equal!")
        }
#endif
    }

}
