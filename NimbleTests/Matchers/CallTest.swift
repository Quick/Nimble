import XCTest
import Nimble

class CallTest : XCTestCase {
    
    let kXCTestMessage = "should pass test\n"
    
    class TestClass : CallRecorder {
        var calledFunctionList = Array<String>()
        var calledArgumentsList = Array<Array<Any>>()
        
        func doStuff() { self.recordCall(function: __FUNCTION__) }
        func doStuffWith(string string: String) { self.recordCall(function: __FUNCTION__, arguments: string) }
//        func doMoreStuffWith(int1 int1: Int, int2: Int) { self.recordCall(function: __FUNCTION__, arguments: int1, int2) }
//        func doWeirdStuffWith(string string: String?, int: Int?) { self.recordCall(function: __FUNCTION__, arguments: string, int) }
//        func doCrazyStuffWith(object object: NSObject) { self.recordCall(function: __FUNCTION__, arguments: object) }
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
        
        // when
        let failingTest = { expect(testClass).to(call(function: "doStuff()")) }
        
        // then
        let expectedMessage = "expected to call <doStuff()> from TestClass, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(expectedMessage) { failingTest() }
    }
    
    func testCallWithCount() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "string")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", count: 1))
    }
    
    func testCallWithCountFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let failingTest1 = { expect(testClass).to(call(function: "doDifferentStuff()", count: 1)) }
        let failingTest2 = { expect(testClass).to(call(function: "doStuff()", count: 2)) }
        
        // then
        let expectedMessage1 = "expected to call <doDifferentStuff()> from TestClass exactly 1 time, got <doStuff()>"
        failsWithErrorMessage(expectedMessage1) { failingTest1() }
        
        let expectedMessage2 = "expected to call <doStuff()> from TestClass exactly 2 times, got <doStuff()>"
        failsWithErrorMessage(expectedMessage2) { failingTest2() }
    }
    
    func testCallWithAtLeast() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "string")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", atLeast: 1))
    }
    
    func testCallWithAtLeastFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let failingTest1 = { expect(testClass).to(call(function: "doDifferentStuff()", atLeast: 1)) }
        let failingTest2 = { expect(testClass).to(call(function: "doStuff()", atLeast: 2)) }
        
        // then
        let expectedMessage1 = "expected to call <doDifferentStuff()> from TestClass at least 1 time, got <doStuff()>"
        failsWithErrorMessage(expectedMessage1) { failingTest1() }
        
        let expectedMessage2 = "expected to call <doStuff()> from TestClass at least 2 times, got <doStuff()>"
        failsWithErrorMessage(expectedMessage2) { failingTest2() }
    }
    
    func testCallWithAtMost() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "string")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", atMost: 1))
    }
    
    func testCallWithAtMostFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // when
        let failingTest1 = { expect(testClass).to(call(function: "doStuffWith(string:)", atMost: 1)) }
        let failingTest2 = { expect(testClass).to(call(function: "doStuff()", atMost: 2)) }
        
        // then
        let got = "got <doStuff()>, <doStuff()>, <doStuff()>, <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        let expectedMessage1 = "expected to call <doStuffWith(string:)> from TestClass at most 1 time, \(got)"
        failsWithErrorMessage(expectedMessage1) { failingTest1() }
        
        let expectedMessage2 = "expected to call <doStuff()> from TestClass at most 2 times, \(got)"
        failsWithErrorMessage(expectedMessage2) { failingTest2() }
    }
    
    func testCallWithParameters() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "string")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["string"]))
    }
    
    func testCallWithParametersFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "swift")
        
        // when
        let failingTest = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["string"])) }
        
        // then
        let expectedMessage = "expected to call <doStuffWith(string:)> from TestClass with string, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(expectedMessage) { failingTest() }
    }
}
