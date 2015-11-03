
/* bug in swift causes every enum WITHOUT an associated value's "description" to be the first declared
enum value WITHOUT an associated value's description
i.e. -> since ".DontCare" is the first enum value then the default description for ".DontCare",
".NonNil", and ".Nil" will all be "DontCare" -> must override to fix issue by conforming to "CustomStringConvertible" */

public enum Argument : CustomStringConvertible {
    case DontCare
    case NonNil
    case Nil
    
    public var description: String {
        switch self {
        case .DontCare:
            return "Argument.DontCare"
        case .NonNil:
            return "Argument.NonNil"
        case .Nil:
            return "Argument.Nil"
        }
    }
}

public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var calledFunctionList = Array<String>()
    // var calledArgumentsList = Array<Array<Any>>()
    var calledFunctionList: Array<String> {get set}
    var calledArgumentsList: Array<Array<Any>> {get set}
    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, arguments: Any...)
    
    // Used if you want to reset the called function/arguments lists
    func clearRecordedLists()
    
    
    // For Internal Use ONLY
    func didCall(function function: String) -> Bool
    func didCall(function function: String, count: Int) -> Bool
    func didCall(function function: String, atLeast count: Int) -> Bool
    func didCall(function function: String, atMost count: Int) -> Bool
    
    func didCall(function function: String, withArgs arguments: Array<Any>) -> Bool
    func didCall(function function: String, withArgs arguments: Array<Any>, count: Int) -> Bool
    func didCall(function function: String, withArgs arguments: Array<Any>, atLeast count: Int) -> Bool
    func didCall(function function: String, withArgs arguments: Array<Any>, atMost count: Int) -> Bool
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
    
    // MARK: Did Call Function
    
    func didCall(function function: String) -> Bool {
        return timesCalled(function) > 0
    }
    
    func didCall(function function: String, count: Int) -> Bool {
        return timesCalled(function) == count
    }
    
    func didCall(function function: String, atLeast count: Int) -> Bool {
        return timesCalled(function) >= count
    }
    
    func didCall(function function: String, atMost count: Int) -> Bool {
        return timesCalled(function) <= count
    }
    
    // MARK: Did Call Function With Arguments
    
    func didCall(function function: String, withArgs arguments: Array<Any>) -> Bool {
        return timesCalled(function: function, arguments: arguments) > 0
    }
    
    func didCall(function function: String, withArgs arguments: Array<Any>, count: Int) -> Bool {
        return timesCalled(function: function, arguments: arguments) == count
    }
    
    func didCall(function function: String, withArgs arguments: Array<Any>, atLeast count: Int) -> Bool {
        return timesCalled(function: function, arguments: arguments) >= count
    }
    
    func didCall(function function: String, withArgs arguments: Array<Any>, atMost count: Int) -> Bool {
        return timesCalled(function: function, arguments: arguments) <= count
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
        if isEqualArgsLists(passedArgs: argsList, recordedArgs: recordedArgsList) {
            correctCallsCount++
        }
    }
    
    return correctCallsCount
}

private func matchingIndexesFor(functionName functionName: String, functionList: Array<String>) -> [Int] {
    return functionList.enumerate().map { functionName == $1 ? $0 : -1 }.filter { $0 != -1 }
}

private func isEqualArgsLists(passedArgs passedArgs: Array<Any>, recordedArgs: Array<Any>) -> Bool {
    if passedArgs.count != recordedArgs.count {
        return false
    }
    
    for var index = 0; index < recordedArgs.count; index++ {
        let passedArg = passedArgs[index]
        let recordedArg = recordedArgs[index]
        
        if !isEqualArgs(passedArg: passedArg, recordedArg: recordedArg) {
            return false
        }
    }
    
    return true
}

private func isEqualArgs(passedArg passedArg: Any, recordedArg: Any) -> Bool {
    if let passedArgAsArgumentEnum = passedArg as? Argument {
        switch passedArgAsArgumentEnum {
        case .DontCare:
            return true
        case .NonNil:
            return !isNil(recordedArg)
        case .Nil:
            return isNil(recordedArg)
        }
    } else {
        return passedArg.dynamicType == recordedArg.dynamicType && "\(passedArg)" == "\(recordedArg)"
    }
}

// Currently best known way to check for nil (Swift doesn't allow -> 'Any' == 'nil')
private func isNil(value: Any) -> Bool {
    let isValueAnOptional = "\(value.dynamicType)".rangeOfString("^Optional<", options: .RegularExpressionSearch, range: nil, locale: nil) != nil
    
    return isValueAnOptional && "\(value)" == "nil"
}
