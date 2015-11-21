import XCTest
import Nimble

class BeNilTest: XCTestCase {
    func testBeNil() {
        expect(nil as Int?).to.beNil()
        expect(1 as Int?).to.not.beNil()
        expect(producesNil()).to.beNil()

        failsWithErrorMessage("expected to not be nil, got <nil>") {
            expect(nil as Int?).to.not.beNil()
        }

        failsWithErrorMessage("expected to be nil, got <1>") {
            expect(1 as Int?).to.beNil()
        }
    }
}

class BeNilDeprecatedTest: XCTestCase {
    func testBeNil() {
        expect(nil as Int?).to(beNil())
        expect(1 as Int?).toNot(beNil())
        expect(producesNil()).to(beNil())

        failsWithErrorMessage("expected to not be nil, got <nil>") {
            expect(nil as Int?).toNot(beNil())
        }

        failsWithErrorMessage("expected to be nil, got <1>") {
            expect(1 as Int?).to(beNil())
        }
    }
}

func producesNil() -> Array<Int>? {
    return nil
}
