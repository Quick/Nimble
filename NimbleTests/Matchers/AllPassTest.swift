import XCTest
import Nimble

class AllPassTest: XCTestCase {
    func testAllPassArray() {
        expect([1,2,3,4]).to(allPass({$0 < 5}))
        expect([1,2,3,4]).toNot(allPass({$0 > 5}))
        
        failsWithErrorMessage(
            "expected to all pass a condition, but failed first at element <3> in <[1, 2, 3, 4]>") {
                expect([1,2,3,4]).to(allPass({$0 < 3}))
        }
        failsWithErrorMessage("expected to not all pass a condition") {
            expect([1,2,3,4]).toNot(allPass({$0 < 5}))
        }
        failsWithErrorMessage(
            "expected to all be something, but failed first at element <3> in <[1, 2, 3, 4]>") {
                expect([1,2,3,4]).to(allPass("be something", {$0 < 3}))
        }
        failsWithErrorMessage("expected to not all be something") {
            expect([1,2,3,4]).toNot(allPass("be something", {$0 < 5}))
        }
    }
    
    func testAllPassMatcher() {
        expect([1,2,3,4]).to(allPass(beLessThan(5)))
        expect([1,2,3,4]).toNot(allPass(beGreaterThan(5)))
        
        failsWithErrorMessage(
            "expected to all be less than <3>, but failed first at element <3> in <[1, 2, 3, 4]>") {
                expect([1,2,3,4]).to(allPass(beLessThan(3)))
        }
        failsWithErrorMessage("expected to not all be less than <5>") {
            expect([1,2,3,4]).toNot(allPass(beLessThan(5)))
        }
    }
    
    func testAllPassSet() {
        expect(Set([1,2,3,4])).to(allPass({$0 < 5}))
        expect(Set([1,2,3,4])).toNot(allPass({$0 > 5}))
        
        failsWithErrorMessage("expected to not all pass a condition") {
            expect(Set([1,2,3,4])).toNot(allPass({$0 < 5}))
        }
        failsWithErrorMessage("expected to not all be something") {
            expect(Set([1,2,3,4])).toNot(allPass("be something", {$0 < 5}))
        }
    }
}