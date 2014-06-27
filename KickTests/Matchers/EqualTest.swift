import XCTest
import Kick

class EqualTest: XCTestCase {

    //    func testEqualityExtension() {
    //        expect(1 as CInt).toEqual(1 as CInt)
    //        expect(1).toEqual(1)
    //        expect("hello").toEqual("hello")
    //        expect("hello").toNotEqual("world")
    //        expect(NSNumber.numberWithInteger(1)).toEqual(NSNumber.numberWithInteger(1))
    //        expect([1, 2, 3]).toEqual([1, 2, 3])
    //        expect([1, 2, 3]).toNotEqual([1, 2, 3, 4])

    //        expect(1 as CInt?).toNotEqual(1)
    //        expect(1 as CInt?).toEqual(1)

    //        expect(nil).toEqual(1)
    //        expect(1).toNotEqual(nil)

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

        expect { NSNumber.numberWithInteger(1) }.to(equal(1))

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
}
