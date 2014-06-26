import XCTest
import Kick

class BeLogicalTest: XCTestCase {
    func testBeTruthy() {
        expect(true).to(beTruthy())
        expect(false).toNot(beTruthy())

        failsWithErrorMessage("expected <false> to be truthy") {
            expect(false).to(beTruthy())
        }
    }

    func testBeTruthyOnOptionals() {
        expect(true as Bool?).to(beTruthy())
        expect(nil as Bool?).toNot(beTruthy())
    }

    func testBeFalsy() {
        expect(false).to(beFalsy())
        expect(true).toNot(beFalsy())

        failsWithErrorMessage("expected <true> to be falsy") {
            expect(true).to(beFalsy())
        }
    }

    func testBeFalsyOnOptionals() {
        expect(nil as Bool?).to(beFalsy())
        expect(true as Bool?).toNot(beFalsy())
    }
}
