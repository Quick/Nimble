import XCTest
import Nimble

class BeLogicalTest: XCTestCase {
    func testBeTruthy() {
        expect(true).to(beTruthy())
        expect(false).toNot(beTruthy())

        failsWithErrorMessage("expected <false> to be truthy") {
            expect(false).to(beTruthy())
        }
    }
    func testBeFalsy() {
        expect(false).to(beFalsy())
        expect(true).toNot(beFalsy())

        failsWithErrorMessage("expected <true> to be falsy") {
            expect(true).to(beFalsy())
        }
    }

    func testOptionals() {
        expect(nil as Bool?).to(beFalsy())
        expect(false as Bool?).to(beFalsy())
        expect(true as Bool?).toNot(beFalsy())
        expect(1 as Int?).toNot(beFalsy())
        expect(nil as Int?).to(beFalsy())

        expect(nil as Bool?).toNot(beTruthy())
        expect(false as Bool?).toNot(beTruthy())
        expect(true as Bool?).to(beTruthy())
        expect(1 as Int?).to(beTruthy())
        expect(nil as Int?).toNot(beTruthy())
    }
}
