
// Implementation Example:


public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var calledFunctionList = Array<String>()
    // var calledArgumentsList = Array<Array<Any>>()
    var calledFunctionList: Array<String> {get set}
    var calledArgumentsList: Array<Array<Any>> {get set}
    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, arguments: Any...)
    
    // Used if you want to reset the called function/parameters lists
    func clearRecordedLists()
    
    
    // For Internal Use ONLY
    func didCall(function function: String) -> Bool
    func didCall(function function: String, withArgs arguments: Array<Any>) -> Bool
}

public extension CallRecorder {
    func recordCall(function function: String, arguments: Any...) {
        self.calledFunctionList.append(function)
        self.calledArgumentsList.append(arguments)
    }
    
    func clearRecordedLists() {
        self.calledFunctionList = Array<String>()
        self.calledArgumentsList = Array<Array<Any>>()
    }
    
    func didCall(function function: String) -> Bool {
        return timesCalled(function) > 0
    }
    
    func didCall(function function: String, withArgs arguments: Array<Any>) -> Bool {
        return timesCalled(function: function, arguments: arguments) > 0
    }
    
    // MARK: Protocol Helper Functions
    
    private func timesCalled(function: String) -> Int {
        return numberOfMatchingCalls(function: function, functions: self.calledFunctionList)
    }
    
    private func timesCalled(function function: String, arguments: Array<Any>) -> Int {
        return numberOfMatchingCalls(function: function, functions: self.calledFunctionList, argsList: arguments, argsLists: self.calledArgumentsList)
    }
}

// MARK: Helper Functions

private func numberOfMatchingCalls(function function: String, functions: Array<String>) -> Int {
    return functions.reduce(0) { $1 == function ? $0 + 1 : $0 }
}

private func numberOfMatchingCalls(function function: String, functions: Array<String>, argsList: Array<Any>, argsLists: Array<Array<Any>>) -> Int {
    let potentialMatchIndexes = matchingIndexesFor(functionName: function, functionList: functions)
    var correctCallsCount = 0
    
    for index in potentialMatchIndexes {
        let recordedArgsList = argsLists[index]
        if isEqualParamsLists(passedParams: argsList, recordedParams: recordedArgsList) {
            correctCallsCount++
        }
    }
    
    return correctCallsCount
}

private func matchingIndexesFor(functionName functionName: String, functionList: Array<String>) -> [Int] {
    return functionList.enumerate().map { functionName == $1 ? $0 : -1 }.filter { $0 != -1 }
}

private func isEqualParamsLists(passedParams passedParams: Array<Any>, recordedParams: Array<Any>) -> Bool {
    if passedParams.count != recordedParams.count {
        return false
    }
    
    for var index = 0; index < recordedParams.count; index++ {
        let passedParam = passedParams[index]
        let recordedParam = recordedParams[index]
        
        if !isEqualParams(passedParam: passedParam, recordedParam: recordedParam) {
            return false
        }
    }
    
    return true
}

private func isEqualParams(passedParam passedParam: Any, recordedParam: Any) -> Bool {
    return passedParam.dynamicType == recordedParam.dynamicType && "\(passedParam)" == "\(recordedParam)"
}
