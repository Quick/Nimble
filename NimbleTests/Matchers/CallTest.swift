import XCTest
import Nimble

class CallTest : XCTestCase {
    
    let kXCTestMessage = "should pass test\n"
    
    class TestClass : CallRecorder {
        var calledFunctionList = Array<String>()
        var calledArgumentsList = Array<Array<Any>>()
        
        func doStuff() { self.recordCall(function: __FUNCTION__) }
        func doStuffWith(string string: String) { self.recordCall(function: __FUNCTION__, arguments: string) }
        func doMoreStuffWith(int1 int1: Int, int2: Int) { self.recordCall(function: __FUNCTION__, arguments: int1, int2) }
        func doWeirdStuffWith(string string: String?, int: Int?) { self.recordCall(function: __FUNCTION__, arguments: string, int) }
        func doCrazyStuffWith(object object: NSObject) { self.recordCall(function: __FUNCTION__, arguments: object) }
    }
    
    func expectDoStuff(object: CallRecorder) {
        expect(object).to(call(function: "doStuff()"))
    }
    
    func testCall() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        
        // then
        expect(testClass).to(call(function: "doStuff()"))
    }
    
    func testCallFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "swift")
        
        // then
        failsWithErrorMessage("expected to call <doStuff()> from TestClass, got <doStuffWith(string:) with swift>") { self.expectDoStuff(testClass) }
    }
}