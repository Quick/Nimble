import XCTest
import Nimble

class CallRecorderTest: XCTestCase {
    
    class TestClass : CallRecorder {
        var calledFunctionList = Array<String>()
        var calledArgumentsList = Array<Array<Any>>()
        
        func doStuff() { self.recordCall(function: __FUNCTION__) }
        func doStuffWith(string string: String) { self.recordCall(function: __FUNCTION__, arguments: string) }
        func doMoreStuffWith(int1 int1: Int, int2: Int) { self.recordCall(function: __FUNCTION__, arguments: int1, int2) }
        func doWeirdStuffWith(string1 string1: String?, string2: String?) { self.recordCall(function: __FUNCTION__, arguments: string1, string2) }
    }
    
    func testRecordingFunctions() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuffWith(string: "asd")
        
        // then
        let expectedRecordedFunctions = ["doStuff()", "doStuff()", "doStuffWith(string:)"]
        expect(testClass.calledFunctionList).to(equal(expectedRecordedFunctions), description: "should record function names in order")
    }
    
    func testRecordingArguments() { // most of these 'expects' are here because Swift's 'Any' Protocol is not Equatable
        // given
        let testClass = TestClass()
        let expectedSet1Arg1 = "foo"
        let expectedSet2Arg1 = 1
        let expectedSet2Arg2 = 2
        let expectedSet3Arg1 = "bar"
        
        // when
        testClass.doStuffWith(string: expectedSet1Arg1)
        testClass.doMoreStuffWith(int1: expectedSet2Arg1, int2: expectedSet2Arg2)
        testClass.doStuffWith(string: expectedSet3Arg1)
        
        // then
        func countFailureMessage(count count: Int, set: Int) -> String {return "should have \(count) argument(s) in set \(set)" }
        func typeFailureMessage(set set: Int, arg: Int) -> String { return "should match type for set \(set), argument \(arg)" }
        func descFailureMessage(set set: Int, arg: Int) -> String { return "should match string interpolation for set \(set), argument \(arg)" }
        
        let actualset1Arg1 = testClass.calledArgumentsList[0][0]
        let actualset2Arg1 = testClass.calledArgumentsList[1][0]
        let actualset2Arg2 = testClass.calledArgumentsList[1][1]
        let actualset3Arg1 = testClass.calledArgumentsList[2][0]
        
        expect(testClass.calledArgumentsList.count).to(equal(3), description: "should have 3 sets of arguments")
        
        expect(testClass.calledArgumentsList[0].count).to(equal(1), description: countFailureMessage(count: 1, set: 1))
        expect("\(actualset1Arg1.dynamicType)").to(equal("\(expectedSet1Arg1.dynamicType)"), description: typeFailureMessage(set: 1, arg: 1))
        expect("\(actualset1Arg1)").to(equal("\(expectedSet1Arg1)"), description: descFailureMessage(set: 1, arg: 1))
        
        expect(testClass.calledArgumentsList[1].count).to(equal(2), description: countFailureMessage(count: 2, set: 2))
        expect("\(actualset2Arg1.dynamicType)").to(equal("\(expectedSet2Arg1.dynamicType)"), description: typeFailureMessage(set: 2, arg: 1))
        expect("\(actualset2Arg1)").to(equal("\(expectedSet2Arg1)"), description: descFailureMessage(set: 2, arg: 1))
        expect("\(actualset2Arg2.dynamicType)").to(equal("\(expectedSet2Arg2.dynamicType)"), description: typeFailureMessage(set: 2, arg: 2))
        expect("\(actualset2Arg2)").to(equal("\(expectedSet2Arg2)"), description: descFailureMessage(set: 2, arg: 2))

        expect(testClass.calledArgumentsList[2].count).to(equal(1), description: countFailureMessage(count: 1, set: 3))
        expect("\(actualset3Arg1.dynamicType)").to(equal("\(expectedSet3Arg1.dynamicType)"), description: typeFailureMessage(set: 3, arg: 1))
        expect("\(actualset3Arg1)").to(equal("\(expectedSet3Arg1)"), description: descFailureMessage(set: 3, arg: 1))
    }
    
    func testResetingTheRecordedLists() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "foo")
        testClass.doMoreStuffWith(int1: 1, int2: 2)
        
        // when
        testClass.clearRecordedLists()
        testClass.doStuffWith(string: "bar")
        
        // then
        expect(testClass.calledFunctionList.count).to(equal(1), description: "should have 1 function recorded")
        let recordedFunction = testClass.calledFunctionList[0] // <- swift doesn't like accessing an array directly in the expect function
        expect(recordedFunction).to(equal("doStuffWith(string:)"), description: "should have correct function recorded")
        
        expect(testClass.calledArgumentsList.count).to(equal(1), description: "should have 1 set of arguments recorded")
        expect(testClass.calledArgumentsList[0].count).to(equal(1), description: "should have 1 argument in first argument set")
        expect("\(testClass.calledArgumentsList[0][0])").to(equal("bar"), description: "should have correct argument in first argument set recorded")
    }
    
    func testDidCallFunction() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()")).to(beTrue(), description: "should have called function")
        expect(testClass.didCall(function: "neverGonnaCall()")).to(beFalse(), description: "should not have called function")
    }
    
    func testDidCallFunctionANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", count: 2)).to(beTrue(), description: "should have called function 2 times")
        expect(testClass.didCall(function: "doStuff()", count: 1)).to(beFalse(), description: "should NOT have called the function 1 time")
        expect(testClass.didCall(function: "doStuff()", count: 3)).to(beFalse(), description: "should NOT have called the function 3 times")
    }
    
    func testDidCallFunctionAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", atLeast: 2)).to(beTrue(), description: "should have called function at least 2 times")
        expect(testClass.didCall(function: "doStuff()", atLeast: 1)).to(beTrue(), description: "should have called function at least 1 time")
        expect(testClass.didCall(function: "doStuff()", atLeast: 3)).to(beFalse(), description: "should NOT have called function at least 3 times")
    }
    
    func testDidCallFunctionAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", atMost: 2)).to(beTrue(), description: "should have called function at most 2 times")
        expect(testClass.didCall(function: "doStuff()", atMost: 3)).to(beTrue(), description: "should have called function at most 3 times")
        expect(testClass.didCall(function: "doStuff()", atMost: 1)).to(beFalse(), description: "should NOT have called function at most 1 time")
    }
    
    func testDidCallFunctionWithArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hi"])).to(beTrue(),
            description: "should have called function with arguments")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"])).to(beFalse(),
            description: "should fail when calling function with wrong arguments")
        expect(testClass.didCall(function: "neverGonnaCallWith(string:)", withArgs: ["hi"])).to(beFalse(),
            description: "should fail when calling wrong function with correct argument")
        expect(testClass.didCall(function: "neverGonnaCallWith(string:)", withArgs: ["nope"])).to(beFalse(),
            description: "should fail when calling wrong function")
    }
    
    func testDidCallFunctionWithOptionalArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string1: "hello", string2: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string1:string2:)", withArgs: ["hello" as String?, nil as String?]))
            .to(beTrue(), description: "should have called correct funtion with correct Optional values")
        expect(testClass.didCall(function: "doWeirdStuffWith(string1:string2:)", withArgs: ["hello", Optional<String>.None]))
            .to(beFalse(), description: "should fail to call correct funtion with correct but Non-Optional values")
    }
    
    func testDidCallFunctionWithArgumentsANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], count: 2)).to(beTrue(),
            description: "should have called function with arguments 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], count: 1)).to(beFalse(),
            description: "should NOT have called function with arguments 1 time")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], count: 3)).to(beFalse(),
            description: "should NOT have called function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atLeast: 2)).to(beTrue(),
            description: "should have called function with arguments at least 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atLeast: 1)).to(beTrue(),
            description: "should have called function with arguments at least 1 time")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atLeast: 3)).to(beFalse(),
            description: "should NOT have called function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atMost: 2)).to(beTrue(),
            description: "should have called function with arguments at most 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atMost: 3)).to(beTrue(),
            description: "should have called function with arguments at most 3 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atMost: 1)).to(beFalse(),
            description: "should NOT have called function with arguments at most 1 time")
    }
    
    func testDidCallFunctionWithDontCareArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doMoreStuffWith(int1: 1, int2: 5)
        testClass.doMoreStuffWith(int1: 1, int2: 6)
        testClass.doWeirdStuffWith(string1: "hi", string2: nil)
        
        // then
        expect(testClass.didCall(function: "doMoreStuffWith(int1:int2:)", withArgs: [1, Argument.DontCare]))
            .to(beTrue(), description: "should have called function with 1 and dont care")
        expect(testClass.didCall(function: "doWeirdStuffWith(string1:string2:)", withArgs: ["hi" as String?, Argument.DontCare]))
            .to(beTrue(), description: "should have called function with non-nil and dont care arguments")
    }
    
    func testDidCallFunctionWithNonNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string1: "hi", string2: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string1:string2:)", withArgs: [Argument.NonNil, Argument.DontCare]))
            .to(beTrue(), description: "should have called function with non-nil and dont care arguments")
        expect(testClass.didCall(function: "doWeirdStuffWith(string1:string2:)", withArgs: [Argument.DontCare, Argument.NonNil]))
            .to(beFalse(), description: "should NOT have called function with non-nil and non-nil arguments")
    }
    
    func testDidCallFunctionWithNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string1: "hi", string2: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string1:string2:)", withArgs: [Argument.DontCare, Argument.Nil]))
            .to(beTrue(), description: "should have called function with dont care and nil arguments")
        expect(testClass.didCall(function: "doWeirdStuffWith(string1:string2:)", withArgs: [Argument.Nil, Argument.DontCare]))
            .to(beFalse(), description: "should NOT have called function with nil and dont care arguments")
    }
}
