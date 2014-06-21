import XCTest
import Tailor


class TailorMatchersTests: XCTestCase {
    func testAsyncPolling() {
        var value = 0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            NSThread.sleepForTimeInterval(0.1)
            value = 1
        }
        expect(value).toEventually(equal(1))

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            NSThread.sleepForTimeInterval(0.1)
            value = 0
        }
        expect(value).toEventuallyNot(equal(1))
    }

    func testAsyncCallback() {
        waitUntil { done in
            done()
        }
        waitUntil { done in
            NSThread.sleepForTimeInterval(0.5)
            done()
        }
        failsWithErrorMessage("Waited more than 1.0 second") {
            waitUntil(timeout: 1) { done in return }
        }
        failsWithErrorMessage("Waited more than 2.0 seconds") {
            waitUntil(timeout: 2) { done in
                NSThread.sleepForTimeInterval(3.0)
                done()
            }
        }

        failsWithErrorMessage("expected <1> to equal <2>") {
            waitUntil { done in
                NSThread.sleepForTimeInterval(0.1)
                expect(1).to(equal(2))
                done()
            }
        }
    }

    func testCapturingOfException() {
        var exception = NSException(name: "laugh", reason: "Lulz", userInfo: nil)
        expect(exception.raise()).to(raiseException(named: "laugh"))
        expect {
            exception.raise()
        }.to(raiseException(named: "laugh"))

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

//    func testEqualityExtension() {
//        expect(1 as Int).toEqual(1 as Int)
//        expect(1).toEqual(1)
//        expect("hello").toEqual("hello")
//        expect("hello").toNotEqual("world")
//        expect(NSNumber.numberWithInteger(1)).toEqual(NSNumber.numberWithInteger(1))
//        expect([1, 2, 3]).toEqual([1, 2, 3])
//        expect([1, 2, 3]).toNotEqual([1, 2, 3, 4])
//
//        expect(1 as CInt?).toNotEqual(1)
//        expect(1 as CInt?).toEqual(1)
//
//        expect(nil).toEqual(1)
//        expect(1).toNotEqual(nil)
//
//        let array1: Array<Int> = [1, 2, 3]
//        let array2: Array<Int> = [1, 2, 3]
//        expect(array1).toEqual(array2)
//    }

    func testEquality() {
        expect(1 as Int).to(equal(1 as Int))
        expect(1).to(equal(1))
        expect("hello").to(equal("hello"))
        expect("hello").toNot(equal("world"))
        expect(NSNumber.numberWithInteger(1)).to(equal(NSNumber.numberWithInteger(1)))
        expect([1, 2, 3]).to(equal([1, 2, 3]))
        expect("foo") == "foo"
        expect("foo") != "bar"

        expect(1 as CInt?).to(equal(1))
        expect(1 as CInt?).to(equal(1 as CInt?))

        expect(nil).toNot(equal(1))
        expect(1).toNot(equal(nil))

        let array1: Array<Int> = [1, 2, 3]
        let array2: Array<Int> = [1, 2, 3]
        expect(array1).to(equal(array2))

        expect {
            1
        }.to(equal(1))

        failsWithErrorMessage("expected <hello> to equal <world>") {
            expect("hello").to(equal("world"))
        }
        failsWithErrorMessage("expected <hello> to not equal <hello>") {
            expect("hello").toNot(equal("hello"))
        }
        failsWithErrorMessage("expected <hello> to equal <world>") {
            expect("hello") == "world"
            return
        }
        failsWithErrorMessage("expected <hello> to not equal <hello>") {
            expect("hello") != "hello"
            return
        }
    }

    func testBeCloseTo() {
        expect(1.2).to(beCloseTo(1.2001))
        expect(1.2).to(beCloseTo(9.300, within: 10))

        failsWithErrorMessage("expected <1.2000> to not be close to <1.2001> (within 0.0001)") {
            expect(1.2).toNot(beCloseTo(1.2001))
        }
        failsWithErrorMessage("expected <1.2000> to not be close to <1.2001> (within 1.0000)") {
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

    func testBeLogicalValue() {
        expect(false).to(beFalsy())
        expect(nil as Bool?).to(beFalsy())
        expect(true).to(beTruthy())
        expect(true as Bool?).to(beTruthy())

        expect(true).toNot(beFalsy())
        expect(false).toNot(beTruthy())


        failsWithErrorMessage("expected <false> to be truthy") {
            expect(false).to(beTruthy())
        }
        failsWithErrorMessage("expected <true> to be falsy") {
            expect(true).to(beFalsy())
        }
    }

    func testBeAnInstanceOf() {
        expect(NSNumber.numberWithInteger(1)).to(beAnInstanceOf(NSNumber))
        expect(NSNumber.numberWithInteger(1)).toNot(beAnInstanceOf(NSString))

        failsWithErrorMessage("expected <1> to be an instance of NSString") {
            expect(NSNumber.numberWithInteger(1)).to(beAnInstanceOf(NSString))
        }
        failsWithErrorMessage("expected <1> to not be an instance of NSNumber") {
            expect(NSNumber.numberWithInteger(1)).toNot(beAnInstanceOf(NSNumber))
        }
    }

    func testContain() {
        expect([1, 2, 3]).to(contain(1))
        expect([1, 2, 3] as CInt[]).to(contain(1))
        expect([1, 2, 3] as Array<CInt>).to(contain(1))
        expect("foo").to(contain("o"))
        expect(["foo", "bar", "baz"]).to(contain("baz"))
        expect([1, 2, 3]).toNot(contain(4))
        expect("foo").toNot(contain("z"))
        expect(["foo", "bar", "baz"]).toNot(contain("ba"))
        expect(NSArray(array: ["a"])).to(contain("a"))
        expect(NSArray(array: ["a"])).toNot(contain("b"))

        failsWithErrorMessage("expected <[a, b, c]> to contain <bar>") {
            expect(["a", "b", "c"]).to(contain("bar"))
        }
        failsWithErrorMessage("expected <[a, b, c]> to not contain <b>") {
            expect(["a", "b", "c"]).toNot(contain("b"))
        }
    }

    func testBeginWith() {
        expect([1, 2, 3]).to(beginWith(1))
        expect([1, 2, 3]).toNot(beginWith(2))
        expect("foobar").to(beginWith("foo"))
        expect("foobar").toNot(beginWith("oo"))
        expect(NSArray(array: ["a", "b"])).to(beginWith("a"))
        expect(NSArray(array: ["a", "b"])).toNot(beginWith("b"))

        failsWithErrorMessage("expected <[1, 2, 3]> to begin with <2>") {
            expect([1, 2, 3]).to(beginWith(2))
        }
        failsWithErrorMessage("expected <[1, 2, 3]> to not begin with <1>") {
            expect([1, 2, 3]).toNot(beginWith(1))
        }
        failsWithErrorMessage("expected <batman> to begin with <atm>") {
            expect("batman").to(beginWith("atm"))
        }
        failsWithErrorMessage("expected <batman> to not begin with <bat>") {
            expect("batman").toNot(beginWith("bat"))
        }
    }

    func testEndWith() {
        expect([1, 2, 3]).to(endWith(3))
        expect([1, 2, 3]).toNot(endWith(2))
        expect("foobar").to(endWith("bar"))
        expect("foobar").toNot(endWith("oo"))
        expect(NSArray(array: ["a", "b"])).to(endWith("b"))
        expect(NSArray(array: ["a", "b"])).toNot(endWith("a"))

        failsWithErrorMessage("expected <[1, 2, 3]> to end with <2>") {
            expect([1, 2, 3]).to(endWith(2))
        }
        failsWithErrorMessage("expected <[1, 2, 3]> to not end with <3>") {
            expect([1, 2, 3]).toNot(endWith(3))
        }
        failsWithErrorMessage("expected <batman> to end with <atm>") {
            expect("batman").to(endWith("atm"))
        }
        failsWithErrorMessage("expected <batman> to not end with <man>") {
            expect("batman").toNot(endWith("man"))
        }
    }
}
