#if _runtime(_ObjC)
    
import XCTest
import Nimble

class ThrowAssertionTest: XCTestCase {
    
    func testPositiveMatch() {
        expect { () throws -> Void in fatalError() }.to(throwAssertion())
    }
    
    func testErrorThrown() {
        expect { throw NSError(domain: "test", code: 0, userInfo: nil) }.toNot(throwAssertion())
    }
    
    func testPostAssertionCodeNotRun() {
        var reachedPoint1 = false
        var reachedPoint2 = false
        
        expect {
            reachedPoint1 = true
            precondition(false, "condition message")
            reachedPoint2 = true
            }.to(throwAssertion())
        
        expect(reachedPoint1) == true
        expect(reachedPoint2) == false
    }
    
    func testNegativeMatch() {
        var reachedPoint1 = false
        
        expect { reachedPoint1 = true }.toNot(throwAssertion())
        
        expect(reachedPoint1) == true
    }
}
    
#endif
