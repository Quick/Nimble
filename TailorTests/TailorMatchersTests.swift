import XCTest
import Tailor

class TailorMatchersTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setAssertionRecorder { assertion, message, file, line in
            XCTAssert(assertion, message, file: file, line: line)
        }
    }

    func testCapturingOfException() {
        var exception = NSException(name: "laugh", reason: "Lulz", userInfo: nil)
        expect(exception.raise()).to(raiseException(named: "laugh"))
        expect {
            exception.raise()
        }.to(raiseException(named :"laugh"))

        expect(exception.raise()).to(raiseException(named: "laugh", reason: "Lulz"))

        failsWithErrorMessage("expected to raise exception named <foo>") {
            expect(exception.raise()).to(raiseException(named: "foo"))
        }
        failsWithErrorMessage("expected to raise exception named <bar> and reason <Lulz>") {
            expect(exception.raise()).to(raiseException(named: "bar", reason: "Lulz"))
        }
        failsWithErrorMessage("expected to not raise exception named <laugh>") {
            expect(exception.raise()).toNot(raiseException(named: "laugh"))
        }
        failsWithErrorMessage("expected to not raise exception named <laugh> and reason <Lulz>") {
            expect(exception.raise()).toNot(raiseException(named: "laugh", reason: "Lulz"))
        }
    }

    func testEquality() {
        expect(1).to(equalTo(1))
        expect("hello").to(equalTo("hello"))
        expect("hello").toNot(equalTo("world"))
        expect(NSNumber.numberWithInteger(1)).to(equalTo(NSNumber.numberWithInteger(1)))
        expect([1, 2, 3]).to(equalTo([1, 2, 3]))
        expect("foo") == "foo"
        expect("foo") != "bar"

        failsWithErrorMessage("expected <hello> to equal to <world>") {
            expect("hello").to(equalTo("world"))
        }
        failsWithErrorMessage("expected <hello> to not equal to <hello>") {
            expect("hello").toNot(equalTo("hello"))
        }
        failsWithErrorMessage("expected <hello> to equal to <world>") {
            expect("hello") == "world"
            return
        }
        failsWithErrorMessage("expected <hello> to not equal to <hello>") {
            expect("hello") != "hello"
            return
        }
    }

    func testBeCloseTo() {
        expect(1.2).to(beCloseTo(1.2001))
        expect(1.2).to(beCloseTo(9.300, within: 10))

        failsWithErrorMessage("expected <1.20000004768372> to not be close to <1.20009994506836> (within 0.00999999977648258)") {
            expect(1.2).toNot(beCloseTo(1.2001))
        }
        failsWithErrorMessage("expected <1.20000004768372> to not be close to <1.20009994506836> (within 1.0)") {
            expect(1.2).toNot(beCloseTo(1.2001, within: 1.0))
        }
    }

    func testBeNil() {
        expect(nil as Int?).to(beNil())
        expect(1 as Int?).toNot(beNil())

        failsWithErrorMessage("expected <nil> to not be nil") {
            expect(nil).toNot(beNil())
        }

        failsWithErrorMessage("expected <1> to be nil") {
            expect(1 as Int?).to(beNil())
        }
    }

    func testGreaterThan() {
        expect(1) > 0
        expect(10).to(beGreaterThan(2))
        expect(1).toNot(beGreaterThan(2))

        failsWithErrorMessage("expected <1> to be greater than <2>") {
            expect(1) > 2
            return
        }
        failsWithErrorMessage("expected <0> to be greater than <2>") {
            expect(0).to(beGreaterThan(2))
            return
        }
        failsWithErrorMessage("expected <1> to not be greater than <0>") {
            expect(1).toNot(beGreaterThan(0))
            return
        }
    }

    func testLessThan() {
        expect(0) < 1
        expect(2).to(beLessThan(10))
        expect(2).toNot(beLessThan(1))

        failsWithErrorMessage("expected <2> to be less than <1>") {
            expect(2) < 1
            return
        }
        failsWithErrorMessage("expected <2> to be less than <0>") {
            expect(2).to(beLessThan(0))
            return
        }
        failsWithErrorMessage("expected <0> to not be less than <1>") {
            expect(0).toNot(beLessThan(1))
            return
        }
    }

    func testLessThanOrEqualTo() {
        expect(0) <= 1
        expect(1) <= 1
        expect(10).to(beLessThanOrEqualTo(10))
        expect(2).to(beLessThanOrEqualTo(10))
        expect(2).toNot(beLessThanOrEqualTo(1))

        failsWithErrorMessage("expected <2> to be less than or equal to <1>") {
            expect(2) <= 1
            return
        }
        failsWithErrorMessage("expected <2> to be less than or equal to <0>") {
            expect(2).to(beLessThanOrEqualTo(0))
            return
        }
        failsWithErrorMessage("expected <0> to not be less than or equal to <0>") {
            expect(0).toNot(beLessThanOrEqualTo(0))
            return
        }
    }

    func testGreaterThanOrEqualTo() {
        expect(0) >= 0
        expect(1) >= 0
        expect(10).to(beGreaterThanOrEqualTo(10))
        expect(10).to(beGreaterThanOrEqualTo(2))
        expect(1).toNot(beGreaterThanOrEqualTo(2))

        failsWithErrorMessage("expected <1> to be greater than or equal to <2>") {
            expect(1) >= 2
            return
        }
        failsWithErrorMessage("expected <0> to be greater than or equal to <2>") {
            expect(0).to(beGreaterThanOrEqualTo(2))
            return
        }
        failsWithErrorMessage("expected <1> to not be greater than or equal to <1>") {
            expect(1).toNot(beGreaterThanOrEqualTo(1))
            return
        }
    }
}
