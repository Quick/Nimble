import XCTest
import Nimble

class CallTest : XCTestCase {
    
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
        expect(testClass).toNot(call(function: "doThings()"))
    }
    
    func testCallFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "swift")
        
        // when
        let toFailingTest = { expect(testClass).to(call(function: "doStuff()")) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuffWith(string:)")) }
        
        // then
        let toExpectedMessage = "expected to call <doStuff()> from TestClass, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }
        
        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
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
        expect(testClass).toNot(call(function: "doStuffWith(string:)", count: 2))
    }
    
    func testCallWithCountFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let toFailingTest1 = { expect(testClass).to(call(function: "doDifferentStuff()", count: 1)) }
        let toFailingTest2 = { expect(testClass).to(call(function: "doStuff()", count: 2)) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuff()", count: 1)) }
        
        // then
        let toExpectedMessage1 = "expected to call <doDifferentStuff()> from TestClass exactly 1 time, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }
        
        let toExpectedMessage2 = "expected to call <doStuff()> from TestClass exactly 2 times, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }
        
        let toNotExpectedMessage = "expected to not call <doStuff()> from TestClass exactly 1 time, got <doStuff()>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
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
        expect(testClass).toNot(call(function: "doStuffWith(string:)", atLeast: 2))
    }
    
    func testCallWithAtLeastFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let toFailingTest1 = { expect(testClass).to(call(function: "doDifferentStuff()", atLeast: 1)) }
        let toFailingTest2 = { expect(testClass).to(call(function: "doStuff()", atLeast: 2)) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuff()", atLeast: 1)) }
        
        // then
        let toExpectedMessage1 = "expected to call <doDifferentStuff()> from TestClass at least 1 time, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }
        
        let toExpectedMessage2 = "expected to call <doStuff()> from TestClass at least 2 times, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }
        
        let toNotExpectedMessage = "expected to not call <doStuff()> from TestClass at least 1 time, got <doStuff()>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
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
        expect(testClass).toNot(call(function: "doStuffWith(string:)", atMost: 0))
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
        let toFailingTest1 = { expect(testClass).to(call(function: "doStuffWith(string:)", atMost: 1)) }
        let toFailingTest2 = { expect(testClass).to(call(function: "doStuff()", atMost: 2)) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuff()", atMost: 4)) }
        
        // then
        let got = "got <doStuff()>, <doStuff()>, <doStuff()>, <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        let toExpectedMessage1 = "expected to call <doStuffWith(string:)> from TestClass at most 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }
        
        let toExpectedMessage2 = "expected to call <doStuff()> from TestClass at most 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }
        
        let toNotExpectedMessage = "expected to not call <doStuff()> from TestClass at most 4 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
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
    
    func testCallWithArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "quick")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["quick"]))
        expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["nimble"]))
    }
    
    func testCallWithArgumentsFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "nimble")
        
        // when
        let toFailingTest = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["quick"])) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["nimble"])) }
        
        // then
        let toExpectedMessage = "expected to call <doStuffWith(string:)> from TestClass with quick, got <doStuffWith(string:) with nimble>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }
        
        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with nimble, got <doStuffWith(string:) with nimble>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
    }
    
    func testCallWithArgumentsFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [])) }
        
        // then
        let expectedMessage = "expected to call function with arguments, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
    
    func testCallWithArgumentsAndCount() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], count: 1))
        expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["nimble"], count: 2))
    }
    
    func testCallWithArgumentsAndCountFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // when
        let toFailingTest1 = { expect(testClass).to(call(function: "doDifferentStuffWith(string:)", withArguments: ["swift"], count: 1)) }
        let toFailingTest2 = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], count: 2)) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["nimble"], count: 1)) }
        
        // then
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        
        let toExpectedMessage1 = "expected to call <doDifferentStuffWith(string:)> from TestClass with swift exactly 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }
        
        let toExpectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with nimble exactly 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }
        
        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with nimble exactly 1 time, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
    }
    
    func testCallWithArgumentsAndCountFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [], count: 1)) }
        
        // then
        let expectedMessage = "expected to call function with arguments count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
    
    func testCallWithArgumentsAndAtLeast() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atLeast: 1))
        expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atLeast: 2))
    }
    
    func testCallWithArgumentsAndAtLeastFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // when
        let toFailingTest1 = { expect(testClass).to(call(function: "doDifferentStuffWith(string:)", withArguments: ["swift"], atLeast: 1)) }
        let toFailingTest2 = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atLeast: 2)) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atLeast: 1)) }
        
        // then
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        
        let toExpectedMessage1 = "expected to call <doDifferentStuffWith(string:)> from TestClass with swift at least 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }
        
        let toExpectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with nimble at least 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }
        
        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with nimble at least 1 time, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
    }
    
    func testCallWithArgumentsAndAtLeastFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [], atLeast: 1)) }
        
        // then
        let expectedMessage = "expected to call function with arguments at least count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
    
    func testCallWithArgumentsAndAtMost() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        
        // then
        expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atMost: 1))
        expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["nimble"], atMost: 0))
    }
    
    func testCallWithArgumentsAndAtMostFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doThingsWith(string: "call matcher")
        testClass.doThingsWith(string: "call matcher")
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")
        
        // when
        let toFailingTest1 = { expect(testClass).to(call(function: "doThingsWith(string:)", withArguments: ["call matcher"], atMost: 1)) }
        let toFailingTest2 = { expect(testClass).to(call(function: "doStuffWith(string:)", withArguments: ["swift"], atMost: 2)) }
        let toNotFailingTest = { expect(testClass).toNot(call(function: "doStuffWith(string:)", withArguments: ["swift"], atMost: 4)) }
        // then
        let got = "got <doThingsWith(string:) with call matcher>, <doThingsWith(string:) with call matcher>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>"
        
        let toExpectedMessage1 = "expected to call <doThingsWith(string:)> from TestClass with call matcher at most 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }
        
        let toExpectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with swift at most 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }
        
        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with swift at most 4 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }
    }
    
    func testCallWithArgumentsAndAtMostFailureMessageForNil() {
        // given
        let nilTestClass : TestClass? = nil
        
        // when
        let failingTest = { expect(nilTestClass).to(call(function: "doStuff()", withArguments: [], atMost: 1)) }
        
        // then
        let expectedMessage = "expected to call function with arguments at most count times, got <nil>"
        failsWithErrorMessageForNil(expectedMessage) { failingTest() }
    }
}
