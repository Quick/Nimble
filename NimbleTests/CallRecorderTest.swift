import XCTest
import Nimble

class CallRecorderTest: XCTestCase {
    
    class TestClass : CallRecorder {
        var calledFunctionList = Array<String>()
        var calledArgumentsList = Array<Array<Any>>()
        
        func doStuff() { self.recordCall(function: __FUNCTION__) }
        func doStuffWith(string string: String) { self.recordCall(function: __FUNCTION__, arguments: string) }
        func doMoreStuffWith(int1 int1: Int, int2: Int) { self.recordCall(function: __FUNCTION__, arguments: int1, int2) }
        func doWeirdStuffWith(string string: String?, int: Int?) { self.recordCall(function: __FUNCTION__, arguments: string, int) }
        func doCrazyStuffWith(object object: NSObject) { self.recordCall(function: __FUNCTION__, arguments: object) }
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
    
    func testResettingTheRecordedLists() {
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
    
    // MARK: Did Call Success Tests
    
    func testDidCallFunction() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function")
        expect(testClass.didCall(function: "neverGonnaCall()", recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function")
    }
    
    func testDidCallFunctionANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", count: 2, recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function 2 times")
        expect(testClass.didCall(function: "doStuff()", count: 1, recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call the function 1 time")
        expect(testClass.didCall(function: "doStuff()", count: 3, recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call the function 3 times")
    }
    
    func testDidCallFunctionAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", atLeast: 2, recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at least 2 times")
        expect(testClass.didCall(function: "doStuff()", atLeast: 1, recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at least 1 time")
        expect(testClass.didCall(function: "doStuff()", atLeast: 3, recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function at least 3 times")
    }
    
    func testDidCallFunctionAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", atMost: 2, recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at most 2 times")
        expect(testClass.didCall(function: "doStuff()", atMost: 3, recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at most 3 times")
        expect(testClass.didCall(function: "doStuff()", atMost: 1, recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function at most 1 time")
    }
    
    func testDidCallFunctionWithArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hi"], recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call correct function with correct arguments")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call correct function with wrong arguments")
        expect(testClass.didCall(function: "neverGonnaCallWith(string:)", withArgs: ["hi"], recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call wrong function with correct argument")
        expect(testClass.didCall(function: "neverGonnaCallWith(string:)", withArgs: ["nope"], recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call wrong function")
    }
    
    func testDidCallFunctionWithOptionalArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hello", int: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: ["hello" as String?, nil as Int?], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call correct funtion with correct Optional values")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: ["hello", Optional<Int>.None], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call correct funtion with correct but Non-Optional values")
    }
    
    func testDidCallFunctionWithArgumentsANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], count: 2, recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], count: 1, recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call function with arguments 1 time")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], count: 3, recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atLeast: 2, recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at least 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atLeast: 1, recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at least 1 time")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atLeast: 3, recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atMost: 2, recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at most 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atMost: 3, recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at most 3 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: ["hello"], atMost: 1, recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call function with arguments at most 1 time")
    }
    
    // MARK: Did Call - Recorded Calls Description Tests
    
    func testDidCallResultShouldIncludeDescriptionOptionYes() {
        // given
        let testClass = TestClass()
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .Yes)
        let result2 : DidCallResult = testClass.didCall(function: "not a function", count: 1, recordedCallsDescOption: .Yes)
        let result3 : DidCallResult = testClass.didCall(function: "not a function", atLeast: 1, recordedCallsDescOption: .Yes)
        let result4 : DidCallResult = testClass.didCall(function: "not a function", atMost: 1, recordedCallsDescOption: .Yes)
        let result5 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], recordedCallsDescOption: .Yes)
        let result6 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], count: 1, recordedCallsDescOption: .Yes)
        let result7 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atLeast: 1, recordedCallsDescOption: .Yes)
        let result8 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atMost: 1, recordedCallsDescOption: .Yes)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(equal("<>")))
    }
    
    func testDidCallResultShouldIncludeDescriptionOptionNo() {
        // given
        let testClass = TestClass()
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .No)
        let result2 : DidCallResult = testClass.didCall(function: "not a function", count: 1, recordedCallsDescOption: .No)
        let result3 : DidCallResult = testClass.didCall(function: "not a function", atLeast: 1, recordedCallsDescOption: .No)
        let result4 : DidCallResult = testClass.didCall(function: "not a function", atMost: 1, recordedCallsDescOption: .No)
        let result5 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], recordedCallsDescOption: .No)
        let result6 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], count: 1, recordedCallsDescOption: .No)
        let result7 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atLeast: 1, recordedCallsDescOption: .No)
        let result8 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atMost: 1, recordedCallsDescOption: .No)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(beEmpty()))
    }
    
    func testDidCallResultShouldIncludeDescriptionOptionOnlyOnUnsuccessForSuccessCase() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "doStuff()", recordedCallsDescOption: .OnlyOnUnsuccess)
        let result2 : DidCallResult = testClass.didCall(function: "doStuff()", count: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result3 : DidCallResult = testClass.didCall(function: "doStuff()", atLeast: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result4 : DidCallResult = testClass.didCall(function: "doStuff()", atMost: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result5 : DidCallResult = testClass.didCall(function: "doStuff()", withArgs: [], recordedCallsDescOption: .OnlyOnUnsuccess)
        let result6 : DidCallResult = testClass.didCall(function: "doStuff()", withArgs: [], count: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result7 : DidCallResult = testClass.didCall(function: "doStuff()", withArgs: [], atLeast: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result8 : DidCallResult = testClass.didCall(function: "doStuff()", withArgs: [], atMost: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(beEmpty()))
    }
    
    func testDidCallResultShouldIncludeDescriptionOptionOnlyOnUnsuccessForUnsuccessCase() {
        // given
        let testClass = TestClass()
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .OnlyOnUnsuccess)
        let result2 : DidCallResult = testClass.didCall(function: "not a function", count: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result3 : DidCallResult = testClass.didCall(function: "not a function", atLeast: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result4 : DidCallResult = testClass.didCall(function: "not a function", atMost: -1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result5 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], recordedCallsDescOption: .OnlyOnUnsuccess)
        let result6 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], count: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result7 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atLeast: 1, recordedCallsDescOption: .OnlyOnUnsuccess)
        let result8 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atMost: -1, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(equal("<>")))
    }
    
    func testDidCallResultShouldIncludeOptionEnumDiscription() {
        // given
        let yes = DidCallResultIncludeOption.Yes
        let no = DidCallResultIncludeOption.No
        let onlyOnUnsuccess = DidCallResultIncludeOption.OnlyOnUnsuccess
        
        // then
        expect("\(yes)").to(equal("DidCallResultIncludeOption.Yes"))
        expect("\(no)").to(equal("DidCallResultIncludeOption.No"))
        expect("\(onlyOnUnsuccess)").to(equal("DidCallResultIncludeOption.OnlyOnUnsuccess"))
    }
    
    func testRecordedCallsDescriptionNoCalls() {
        // given
        let testClass = TestClass()
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .Yes)
        let result2 : DidCallResult = testClass.didCall(function: "not a function", count: 1, recordedCallsDescOption: .Yes)
        let result3 : DidCallResult = testClass.didCall(function: "not a function", atLeast: 1, recordedCallsDescOption: .Yes)
        let result4 : DidCallResult = testClass.didCall(function: "not a function", atMost: -1, recordedCallsDescOption: .Yes)
        let result5 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], recordedCallsDescOption: .Yes)
        let result6 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], count: 1, recordedCallsDescOption: .Yes)
        let result7 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atLeast: 1, recordedCallsDescOption: .Yes)
        let result8 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atMost: -1, recordedCallsDescOption: .Yes)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(equal("<>")))
    }
    
    func testRecordedCallsDescriptionSingleCallWithNoArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .Yes)
        let result2 : DidCallResult = testClass.didCall(function: "not a function", count: 1, recordedCallsDescOption: .Yes)
        let result3 : DidCallResult = testClass.didCall(function: "not a function", atLeast: 1, recordedCallsDescOption: .Yes)
        let result4 : DidCallResult = testClass.didCall(function: "not a function", atMost: -1, recordedCallsDescOption: .Yes)
        let result5 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], recordedCallsDescOption: .Yes)
        let result6 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], count: 1, recordedCallsDescOption: .Yes)
        let result7 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atLeast: 1, recordedCallsDescOption: .Yes)
        let result8 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atMost: -1, recordedCallsDescOption: .Yes)
        
        print(result1)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(equal("<doStuff()>")))
    }
    
    func testRecordedCallsDescriptionSingleCallWithArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doMoreStuffWith(int1: 5, int2: 10)
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .Yes)
        let result2 : DidCallResult = testClass.didCall(function: "not a function", count: 1, recordedCallsDescOption: .Yes)
        let result3 : DidCallResult = testClass.didCall(function: "not a function", atLeast: 1, recordedCallsDescOption: .Yes)
        let result4 : DidCallResult = testClass.didCall(function: "not a function", atMost: -1, recordedCallsDescOption: .Yes)
        let result5 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], recordedCallsDescOption: .Yes)
        let result6 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], count: 1, recordedCallsDescOption: .Yes)
        let result7 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atLeast: 1, recordedCallsDescOption: .Yes)
        let result8 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atMost: -1, recordedCallsDescOption: .Yes)
        
        print(result1)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(equal("<doMoreStuffWith(int1:int2:) with 5, 10>")))
    }
    
    func testRecordedCallsDescriptionMultipleCalls() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doMoreStuffWith(int1: 5, int2: 10)
        
        // then
        let result1 : DidCallResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .Yes)
        let result2 : DidCallResult = testClass.didCall(function: "not a function", count: 1, recordedCallsDescOption: .Yes)
        let result3 : DidCallResult = testClass.didCall(function: "not a function", atLeast: 1, recordedCallsDescOption: .Yes)
        let result4 : DidCallResult = testClass.didCall(function: "not a function", atMost: -1, recordedCallsDescOption: .Yes)
        let result5 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], recordedCallsDescOption: .Yes)
        let result6 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], count: 1, recordedCallsDescOption: .Yes)
        let result7 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atLeast: 1, recordedCallsDescOption: .Yes)
        let result8 : DidCallResult = testClass.didCall(function: "not a function", withArgs: [], atMost: -1, recordedCallsDescOption: .Yes)
        
        print(result1)
        
        let recordedCallsDescriptions = [result1.recordedCallsDescription,
                                         result2.recordedCallsDescription,
                                         result3.recordedCallsDescription,
                                         result4.recordedCallsDescription,
                                         result5.recordedCallsDescription,
                                         result6.recordedCallsDescription,
                                         result7.recordedCallsDescription,
                                         result8.recordedCallsDescription]
        
        expect(recordedCallsDescriptions).to(allPass(equal("<doStuff()>, <doMoreStuffWith(int1:int2:) with 5, 10>")))
    }
    
    // MARK: Argument Enum Tests
    
    func testArgumentEnumDiscription() {
        // given
        let dontCare = Argument.DontCare
        let nonNil = Argument.NonNil
        let nilly = Argument.Nil
        let instanceOf = Argument.InstanceOf(type: String.self)
        let instanceOfWith = Argument.InstanceOfWith(type: String.self, option: .DontCare)
        let kindOf = Argument.KindOf(type: NSObject.self)
        
        // then
        expect("\(dontCare)").to(equal("Argument.DontCare"))
        expect("\(nonNil)").to(equal("Argument.NonNil"))
        expect("\(nilly)").to(equal("Argument.Nil"))
        expect("\(instanceOf)").to(equal("Argument.InstanceOf(String)"))
        expect("\(instanceOfWith)").to(equal("Argument.InstanceOfWith(String, ArgumentOption.DontCare)"))
        expect("\(kindOf)").to(equal("Argument.KindOf(NSObject)"))
    }
    
    func testArgumentOptionEnumDescription() {
        let dontCare = ArgumentOption.DontCare
        let nonOptional = ArgumentOption.NonOptional
        let optional = ArgumentOption.Optional
        
        // then
        expect("\(dontCare)").to(equal("ArgumentOption.DontCare"))
        expect("\(nonOptional)").to(equal("ArgumentOption.NonOptional"))
        expect("\(optional)").to(equal("ArgumentOption.Optional"))
    }
    
    func testDontCareArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doMoreStuffWith(int1: 1, int2: 5)
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doMoreStuffWith(int1:int2:)", withArgs: [Argument.DontCare, Argument.DontCare], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with 1 and dont care")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: [Argument.DontCare, Argument.DontCare], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with non-nil and dont care arguments")
    }
    
    func testNonNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: [Argument.NonNil, Argument.DontCare], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with non-nil and dont care arguments")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: [Argument.DontCare, Argument.NonNil], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with non-nil and non-nil arguments")
    }
    
    func testNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: [Argument.DontCare, Argument.Nil], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with dont care and nil arguments")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: [Argument.Nil, Argument.DontCare], recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with nil and dont care arguments")
    }
    
    func testInstanceOfArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: [Argument.InstanceOf(type: String.self)], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with instance of String argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: [Argument.InstanceOf(type: Int.self)], recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with instance of Int argument")
        
        let expectedArgs1: Array<Any> = [Argument.InstanceOf(type: Optional<String>.self), Argument.InstanceOf(type: Optional<Int>.self)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: expectedArgs1, recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with instance of String? and Int? arguments")
        let expectedArgs2: Array<Any> = [Argument.InstanceOf(type: String.self), Argument.InstanceOf(type: Int.self)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: expectedArgs2, recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with String and Int arguments")
    }
    
    func testInstanceOfWithArgumentDontCareArgumentOption() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: 5)
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: [Argument.InstanceOfWith(type: String.self, option: .DontCare)], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with instance of String with optional requirement 'dont care' argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: [Argument.InstanceOfWith(type: Int.self, option: .DontCare)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with instance of Int with optional requirement 'dont care' argument")
    }
    
    func testInstanceOfWithArgumentNonOptionalArgumentOption() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: 5)
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: [Argument.InstanceOfWith(type: String.self, option: .NonOptional)], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with instance of String with optional requirement 'non-optional' argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: [Argument.InstanceOfWith(type: Int.self, option: .NonOptional)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with instance of Int with optional requirement 'non-optional' argument")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: [Argument.DontCare, Argument.InstanceOfWith(type: Int.self, option: .NonOptional)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with 'dont care' and instance of Int with optional requirement 'non-optional' arguments")
    }
    
    func testInstanceOfWithArgumentOptionalArgumentOption() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: 5)
        
        // then
        let expectedArgs1: Array<Any> = [Argument.DontCare, Argument.InstanceOfWith(type: Int.self, option: .Optional)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: expectedArgs1, recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with 'dont care' and instance of Int with optional requirement 'optional' argument")
        let expectedArgs2: Array<Any> = [Argument.DontCare, Argument.InstanceOfWith(type: String.self, option: .Optional)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArgs: expectedArgs2, recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with 'dont care' and instance of String with optional requirement 'optional' argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArgs: [Argument.InstanceOfWith(type: String.self, option: .Optional)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with instance of String with optional requirement 'optional' arguments")
    }
    
    func testKindOfClassArgument() {
        // given
        class SubClass : NSObject {}
        class SubSubClass : SubClass {}
        let testClass = TestClass()
        
        // when
        testClass.doCrazyStuffWith(object: SubClass())
        
        // then
        expect(testClass.didCall(function: "doCrazyStuffWith(object:)", withArgs: [Argument.KindOf(type: NSObject.self)], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with kind of NSObject argument")
        expect(testClass.didCall(function: "doCrazyStuffWith(object:)", withArgs: [Argument.KindOf(type: SubClass.self)], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with kind of SubClass argument")
        expect(testClass.didCall(function: "doCrazyStuffWith(object:)", withArgs: [Argument.KindOf(type: SubSubClass.self)], recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with kind of SubSubClass argument")
    }
}
