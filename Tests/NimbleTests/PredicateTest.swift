import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class MatcherTest: XCTestCase {
    func testDefineDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Matcher.define { _, msg in MatcherResult(status: .fail, message: msg) })
        }
    }

    func testDefineNilableDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Matcher.defineNilable { _, msg in MatcherResult(status: .fail, message: msg) })
        }
    }

    func testSimpleDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Matcher.simple { _ in .fail })
        }
    }

    func testSimpleNilableDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Matcher.simpleNilable { _ in .fail })
        }
    }
}
