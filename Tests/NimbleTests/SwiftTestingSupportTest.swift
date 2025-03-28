#if canImport(Testing)
import Nimble
import Testing
import XCTest

@Suite struct SwiftTestingSupportSuite {
    @Test func reportsAssertionFailuresToSwiftTesting() {
        withKnownIssue {
            expect(1).to(equal(2))
        }
    }

    @Test func reportsRequireErrorsToSwiftTesting() throws {
        withKnownIssue {
            try require(false).to(beTrue())
        }
    }
}

#if canImport(Darwin)
// the open source version of XCTest doesn't include `XCTExpectFailure`.
class MixedSwiftTestingXCTestSupport: XCTestCase {
    func testAlsoRecordsErrorsToXCTest() {
        XCTExpectFailure("This should fail")
        fail()

    }

    func testAlsoRecordsRequireErrorsToXCTest() throws {
        XCTExpectFailure("This should fail")
        try require(false).to(beTrue())
    }
}
#endif

#endif
