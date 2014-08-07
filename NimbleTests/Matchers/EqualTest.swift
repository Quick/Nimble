import XCTest
import Nimble

class EqualTest: XCTestCase {
    func testEquality() {
        expect(1 as CInt).to(equal(1 as CInt))
        expect(1 as CInt).to(equal(1))
        expect(1).to(equal(1 as CInt))
        expect(1).to(equal(1))
        expect("hello").to(equal("hello"))
        expect("hello").toNot(equal("world"))

        expect {
            1
        }.to(equal(1))

        failsWithErrorMessage("expected <hello> to equal <world>") {
            expect("hello").to(equal("world"))
        }
        failsWithErrorMessage("expected <hello> to not equal <hello>") {
            expect("hello").toNot(equal("hello"))
        }
    }

    func testArrayEquality() {
        expect([1, 2, 3]).to(equal([1, 2, 3]))
        expect([1, 2, 3]).toNot(equal([1, 2]))

        let array1: Array<Int> = [1, 2, 3]
        let array2: Array<Int> = [1, 2, 3]
        expect(array1).to(equal(array2))
        expect(array1).to(equal([1, 2, 3]))
        expect(array1).toNot(equal([1, 2] as Array<Int>))

        expect(NSArray(array: [1, 2, 3])).to(equal(NSArray(array: [1, 2, 3])))
    }

    func testNSObjectEquality() {
        expect(NSNumber.numberWithInteger(1)).to(equal(NSNumber.numberWithInteger(1)))
        expect(NSNumber.numberWithInteger(1)) == NSNumber.numberWithInteger(1)
        expect(NSNumber.numberWithInteger(1)) != NSNumber.numberWithInteger(2)
        expect { NSNumber.numberWithInteger(1) }.to(equal(1))
    }

    func testOperatorEquality() {
        expect("foo") == "foo"
        expect("foo") != "bar"

        failsWithErrorMessage("expected <hello> to equal <world>") {
            expect("hello") == "world"
            return
        }
        failsWithErrorMessage("expected <hello> to not equal <hello>") {
            expect("hello") != "hello"
            return
        }
    }

    func testOptionalEquality() {
        expect(1 as CInt?).to(equal(1))
        expect(1 as CInt?).to(equal(1 as CInt?))
        expect(nil as NSObject?).toNot(equal(1))

        expect(1).toNot(equal(nil))
    }
}
