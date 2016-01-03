import XCTest
import Nimble

class SatisfyOneOfTest: XCTestCase {
    func testSatisfyOneOf() {
        expect(2).to(satisfyOneOf(equal(2), equal(3)))
        expect(2).toNot(satisfyOneOf(equal(3), equal("turtles")))
        expect([1,2,3]).to(satisfyOneOf(equal([1,2,3]), allPass({$0 < 4}), haveCount(3)))
        
        failsWithErrorMessage(
            "expected to match one of: {equal <3>}, {equal <4>}, {equal <5>}, got 2") {
                expect(2).to(satisfyOneOf(equal(3), equal(4), equal(5)))
        }
        failsWithErrorMessage(
            "expected to match one of: {all be less than 4, but failed first at element <5> in <[5, 6, 7]>}, {equal <[1, 2, 3, 4]>}, got [5, 6, 7]") {
                expect([5,6,7]).to(satisfyOneOf(allPass("be less than 4", {$0 < 4}), equal([1,2,3,4])))
        }
    }
}
