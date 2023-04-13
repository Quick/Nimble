import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class StatusTest: XCTestCase {

    func testUnexecuted() {
        producesStatus(.pending) {
            expect(true)
        }
    }

    func testSingleExecution() {
        producesStatus(.passed) {
            expect(true).to(beTrue())
        }

        producesStatus(.failed) {
            expect(true).to(beFalse())
        }
    }

    func testChainedExecution() {
        producesStatus(.passed) {
            expect(true).to(beTrue()).to(beTrue())
        }

        producesStatus(.failed) {
            expect(true).to(beFalse()).to(beFalse())
        }

        producesStatus(.mixed) {
            expect(true).to(beTrue()).to(beFalse())
        }

        producesStatus(.mixed) {
            expect(true).to(beFalse()).to(beTrue())
        }
    }

    #if !os(WASI)
    func testAsync() {
        producesStatus(.passed) {
            expect(true).toEventually(beTrue())
        }

        producesStatus(.failed) {
            expect(true).toEventually(beFalse())
        }
    }
    #endif
}
