import XCTest
import Kick

class BeNilTest: XCTestCase {
    func testBeNil() {
        expect(nil as Int?).to(beNil())
        expect(1 as Int?).toNot(beNil())

        failsWithErrorMessage("expected <nil> to not be nil") {
            expect(nil as Int?).toNot(beNil())
        }

        failsWithErrorMessage("expected <1> to be nil") {
            expect(1 as Int?).to(beNil())
        }
    }

    func testBeNilExplicitNilType() {
        expect(nil).to(beNil())

        failsWithErrorMessage("expected <nil> to not be nil") {
            expect(nil).toNot(beNil())
        }
    }
}
