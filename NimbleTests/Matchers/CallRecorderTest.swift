import XCTest
import Nimble

class CallRecorderTest: XCTestCase {
    
    class TestExample : CallRecorder {
        var calledFunctionList = Array<String>()
        var calledParametersList = Array<Array<NSObject>>()
        
        func doStuff() {
            self.recordCall(function: __FUNCTION__)
        }
        
        func doStuffWith(string string: String) {
            self.recordCall(function: __FUNCTION__)
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
}




























