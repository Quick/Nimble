import XCTest
import Kick

class ContainTest: XCTestCase {
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
}
