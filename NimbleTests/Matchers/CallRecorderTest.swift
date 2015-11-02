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
        XCTAssertEqual(testExample.calledFunctionList, expectedRecordedFunctions, "should record function names in order")
    }
    
    func testRecordingArguments() { // most of these tests are here because Swift's 'Any' Protocol is not Equatable
        // given
        let testExample = TestExample()
        let set1Arg1 = "one"
        let set2Arg1 = 5
        let set2Arg2 = 10
        let set3Arg1 = "three"
        
        // when
        testExample.doStuffWith(string: set1Arg1)
        testExample.doMoreStuffWith(int1: set2Arg1, int2: set2Arg2)
        testExample.doStuffWith(string: set3Arg1)
        
        
        // then
        func countFailureMessage(count count: Int, set: Int) -> String {return "should have \(count) argument(s) in set \(set)" }
        func typeFailureMessage(set set: Int, arg: Int) -> String { return "should match type for set \(set), argument \(arg)" }
        func descFailureMessage(set set: Int, arg: Int) -> String { return "should match string interpolation for set \(set), argument \(arg)" }
        
        XCTAssertEqual(testExample.calledArgumentsList.count, 3, "should have 3 sets of Arguments")
        
        XCTAssertEqual(testExample.calledArgumentsList[0].count, 1, countFailureMessage(count: 1, set: 1))
        XCTAssertEqual("\(testExample.calledArgumentsList[0][0].dynamicType)", "\(set1Arg1.dynamicType)", typeFailureMessage(set: 1, arg: 1))
        XCTAssertEqual("\(testExample.calledArgumentsList[0][0])", "\(set1Arg1)", descFailureMessage(set: 1, arg: 1))
        
        XCTAssertEqual(testExample.calledArgumentsList[1].count, 2, countFailureMessage(count: 2, set: 2))
        XCTAssertEqual("\(testExample.calledArgumentsList[1][0].dynamicType)", "\(set2Arg1.dynamicType)", typeFailureMessage(set: 2, arg: 1))
        XCTAssertEqual("\(testExample.calledArgumentsList[1][0])", "\(set2Arg1)", descFailureMessage(set: 2, arg: 1))
        XCTAssertEqual("\(testExample.calledArgumentsList[1][1].dynamicType)", "\(set2Arg2.dynamicType)", typeFailureMessage(set: 2, arg: 2))
        XCTAssertEqual("\(testExample.calledArgumentsList[1][1])", "\(set2Arg2)", descFailureMessage(set: 2, arg: 2))

        XCTAssertEqual(testExample.calledArgumentsList[2].count, 1, countFailureMessage(count: 1, set: 3))
        XCTAssertEqual("\(testExample.calledArgumentsList[2][0].dynamicType)", "\(set3Arg1.dynamicType)", typeFailureMessage(set: 3, arg: 1))
        XCTAssertEqual("\(testExample.calledArgumentsList[2][0])", "\(set3Arg1)", descFailureMessage(set: 3, arg: 1))
    }
}
