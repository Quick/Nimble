import XCTest
import Nimble

class CallRecorderTest: XCTestCase {
    
    class TestExample : CallRecorder {
        var calledFunctionList = Array<String>()
        var calledArgumentsList = Array<Array<Any>>()
        
        func doStuff() {
            self.recordCall(function: __FUNCTION__)
        }
        
        func doStuffWith(string string: String) {
            self.recordCall(function: __FUNCTION__, arguments: string)
        }
        
        func doMoreStuffWith(int1 int1: Int, int2: Int) {
            self.recordCall(function: __FUNCTION__, arguments: int1, int2)
        }
    }
    
    func testRecordingFunctions() {
        // given
        let testExample = TestExample()
        
        // when
        testExample.doStuff()
        testExample.doStuff()
        testExample.doStuffWith(string: "asd")
        
        // then
        let expectedRecordedFunctions = ["doStuff()", "doStuff()", "doStuffWith(string:)"]
        expect(testExample.calledFunctionList).to(equal(expectedRecordedFunctions), description: "should record function names in order")
    }
    
    func testRecordingArguments() { // most of these tests are here because Swift's 'Any' Protocol is not Equatable
        // given
        let testExample = TestExample()
        let expectedSet1Arg1 = "foo"
        let expectedSet2Arg1 = 1
        let expectedSet2Arg2 = 2
        let expectedSet3Arg1 = "bar"
        
        // when
        testExample.doStuffWith(string: expectedSet1Arg1)
        testExample.doMoreStuffWith(int1: expectedSet2Arg1, int2: expectedSet2Arg2)
        testExample.doStuffWith(string: expectedSet3Arg1)
        
        // then
        func countFailureMessage(count count: Int, set: Int) -> String {return "should have \(count) argument(s) in set \(set)" }
        func typeFailureMessage(set set: Int, arg: Int) -> String { return "should match type for set \(set), argument \(arg)" }
        func descFailureMessage(set set: Int, arg: Int) -> String { return "should match string interpolation for set \(set), argument \(arg)" }
        
        let actualset1Arg1 = testExample.calledArgumentsList[0][0]
        let actualset2Arg1 = testExample.calledArgumentsList[1][0]
        let actualset2Arg2 = testExample.calledArgumentsList[1][1]
        let actualset3Arg1 = testExample.calledArgumentsList[2][0]
        
        expect(testExample.calledArgumentsList.count).to(equal(3), description: "should have 3 sets of arguments")
        
        expect(testExample.calledArgumentsList[0].count).to(equal(1), description: countFailureMessage(count: 1, set: 1))
        expect("\(actualset1Arg1.dynamicType)").to(equal("\(expectedSet1Arg1.dynamicType)"), description: typeFailureMessage(set: 1, arg: 1))
        expect("\(actualset1Arg1)").to(equal("\(expectedSet1Arg1)"), description: descFailureMessage(set: 1, arg: 1))
        
        expect(testExample.calledArgumentsList[1].count).to(equal(2), description: countFailureMessage(count: 2, set: 2))
        expect("\(actualset2Arg1.dynamicType)").to(equal("\(expectedSet2Arg1.dynamicType)"), description: typeFailureMessage(set: 2, arg: 1))
        expect("\(actualset2Arg1)").to(equal("\(expectedSet2Arg1)"), description: descFailureMessage(set: 2, arg: 1))
        expect("\(actualset2Arg2.dynamicType)").to(equal("\(expectedSet2Arg2.dynamicType)"), description: typeFailureMessage(set: 2, arg: 2))
        expect("\(actualset2Arg2)").to(equal("\(expectedSet2Arg2)"), description: descFailureMessage(set: 2, arg: 2))

        expect(testExample.calledArgumentsList[2].count).to(equal(1), description: countFailureMessage(count: 1, set: 3))
        expect("\(actualset3Arg1.dynamicType)").to(equal("\(expectedSet3Arg1.dynamicType)"), description: typeFailureMessage(set: 3, arg: 1))
        expect("\(actualset3Arg1)").to(equal("\(expectedSet3Arg1)"), description: descFailureMessage(set: 3, arg: 1))
    }
    
    func testResetingTheRecordedLists() {
        // given
        let testExample = TestExample()
        testExample.doStuffWith(string: "foo")
        testExample.doMoreStuffWith(int1: 1, int2: 2)
        
        // when
        testExample.clearRecordedLists()
        testExample.doStuffWith(string: "bar")
        
        // then
        expect(testExample.calledFunctionList.count).to(equal(1), description: "should have 1 function recorded")
        let recordedFunction = testExample.calledFunctionList[0] // <- swift doesn't like accessing an array directly in the expect function
        expect(recordedFunction).to(equal("doStuffWith(string:)"), description: "should have correct function recorded")
        
        expect(testExample.calledArgumentsList.count).to(equal(1), description: "should have 1 set of arguments recorded")
        expect(testExample.calledArgumentsList[0].count).to(equal(1), description: "should have 1 argument in first argument set")
        expect("\(testExample.calledArgumentsList[0][0])").to(equal("bar"), description: "should have correct argument in first argument set recorded")
    }
    
    func testDidCallFunction() {
        // given
        let testExample = TestExample()
        
        // when
        testExample.doStuff()
        
        // then
        expect(testExample.didCall(function: "doStuff()")).to(beTrue(), description: "should have called function")
        expect(testExample.didCall(function: "neverGonnaCall()")).to(beFalse(), description: "should not have called function")
    }
}
