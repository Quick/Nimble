#if canImport(Testing)
import Nimble
import Testing
import XCTest

@Suite struct SwiftTestingSupportSuite {
    @Test func reportsAssertionFailuresToSwiftTesting() {
        withKnownIssue {
            fail()
        }
    }

    @Test func reportsRequireErrorsToSwiftTesting() throws {
        withKnownIssue {
            try require(false).to(beTrue())
        }
    }
}

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
