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
// XCTExpectFailure is only available on the closed-source implementation
// of XCTest.
// https://github.com/swiftlang/swift-corelibs-xctest/issues/438
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
