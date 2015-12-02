import XCTest
import Nimble

class CallTest : XCTestCase {
    
    let kXCTestMessage = "should pass test\n"
    
    class TestClass : CallRecorder {
        var calledFunctionList = Array<String>()
        var calledArgumentsList = Array<Array<Any>>()
        
        func doStuff() { self.recordCall(function: __FUNCTION__) }
        func doStuffWith(string string: String) { self.recordCall(function: __FUNCTION__, arguments: string) }
        func doThingsWith(string string: String) { self.recordCall(function: __FUNCTION__, arguments: string) }
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
    
    func testCallFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()")) }
        
        // then
        let expectedMessage = "expected to call function, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
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
    
    func testCallWithCountFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", count: 1)) }
        
        // then
        let expectedMessage = "expected to call function count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
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
    
    func testCallWithAtLeastFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", atLeast: 1)) }
        
        // then
        let expectedMessage = "expected to call function at least count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
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
    
    func testCallWithAtMostFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", atMost: 1)) }
        
        // then
        let expectedMessage = "expected to call function at most count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
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
    
    func testCallWithParametersFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [])) }
        
        // then
        let expectedMessage = "expected to call function with arguments, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
    
    func testCallWithParametersAndCount() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], count: 1))
    }
    
    func testCallWithParametersAndCountFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // when
        let failingTest1 = { expect(testClass).to(call(function: "doDifferentStuffWith(string:)", withArguments: ["swift"], count: 1)) }
        let failingTest2 = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], count: 2)) }
        
        // then
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        
        let expectedMessage1 = "expected to call <doDifferentStuffWith(string:)> from TestClass with swift exactly 1 time, \(got)"
        failsWithErrorMessage(expectedMessage1) { failingTest1() }
        
        let expectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with nimble exactly 2 times, \(got)"
        failsWithErrorMessage(expectedMessage2) { failingTest2() }
    }
    
    func testCallWithParametersAndCountFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [], count: 1)) }
        
        // then
        let expectedMessage = "expected to call function with arguments count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
    
    func testCallWithParametersAndAtLeast() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atLeast: 1))
    }
    
    func testCallWithParametersAndAtLeastFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // when
        let failingTest1 = { expect(testClass).to(call(function: "doDifferentStuffWith(string:)", withArguments: ["swift"], atLeast: 1)) }
        let failingTest2 = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atLeast: 2)) }
        
        // then
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        
        let expectedMessage1 = "expected to call <doDifferentStuffWith(string:)> from TestClass with swift at least 1 time, \(got)"
        failsWithErrorMessage(expectedMessage1) { failingTest1() }
        
        let expectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with nimble at least 2 times, \(got)"
        failsWithErrorMessage(expectedMessage2) { failingTest2() }
    }
    
    func testCallWithParametersAndAtLeastFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [], atLeast: 1)) }
        
        // then
        let expectedMessage = "expected to call function with arguments at least count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
    
    func testCallWithParametersAndAtMost() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atMost: 1))
    }
    
    func testCallWithParametersAndAtMostFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doThingsWith(string: "call matcher")
        testClass.doThingsWith(string: "call matcher")
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")
        
        // when
        let failingTest1 = { expect(testClass).to(call(function: "doThingsWith(string:)", withArguments: ["call matcher"], atMost: 1)) }
        let failingTest2 = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["swift"], atMost: 2)) }
        
        // then
        let got = "got <doThingsWith(string:) with call matcher>, <doThingsWith(string:) with call matcher>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>"
        
        let expectedMessage1 = "expected to call <doThingsWith(string:)> from TestClass with call matcher at most 1 time, \(got)"
        failsWithErrorMessage(expectedMessage1) { failingTest1() }
        
        let expectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with swift at most 2 times, \(got)"
        failsWithErrorMessage(expectedMessage2) { failingTest2() }
    }
    
    func testCallWithParametersAndAtMostFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [], atMost: 1)) }
        
        // then
        let expectedMessage = "expected to call function with arguments at most count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
}
