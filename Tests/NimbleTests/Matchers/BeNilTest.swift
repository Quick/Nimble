import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class BeNilTest: XCTestCase {
    func producesNil() -> [Int]? {
        return nil
    }

    func testBeNil() {
        expect(nil as Int?).to(beNil())
        expect(nil as Int?) == nil

        expect(1 as Int?).toNot(beNil())
        expect(1 as Int?) != nil

        expect(self.producesNil()).to(beNil())
        expect(self.producesNil()) == nil

        do {
            let message = "expected to not be nil, got <nil>"
            failsWithErrorMessage(message) {
                expect(nil as Int?).toNot(beNil())
            }
            failsWithErrorMessage(message) {
                expect(nil as Int?) != nil
            }
        }

        do {
            let message = "expected to be nil, got <1>"
            failsWithErrorMessage(message) {
                expect(1 as Int?).to(beNil())
            }
            failsWithErrorMessage(message) {
                expect(1 as Int?) == nil
            }
        }
    }
}
