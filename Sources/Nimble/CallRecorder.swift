
/* bug in Swift causes every enum WITHOUT an associated value's "description" to be the first declared
enum value WITHOUT an associated value's description
i.e. -> since ".Anything" is the first enum value then the default description for ".Anything",
".NonNil", and ".Nil" will all be "Anything" -> must override to fix issue by conforming to "CustomStringConvertible" 
    This is not reproducable in a Playground */

public enum Argument : CustomStringConvertible {
    case Anything
    case NonNil
    case Nil
    case InstanceOf(type: Any.Type)
    case InstanceOfWith(type: Any.Type, option: ArgumentOption)
    case KindOf(type: AnyObject.Type)
    
    public var description: String {
        switch self {
        case .Anything:
            return "Argument.Anything"
        case .NonNil:
            return "Argument.NonNil"
        case .Nil:
            return "Argument.Nil"
        case .InstanceOf(let type):
            return "Argument.InstanceOf(\(type))"
        case .InstanceOfWith(let input):
            return "Argument.InstanceOfWith(\(input.type), \(input.option))"
        case .KindOf(let type):
            return "Argument.KindOf(\(type))"
        }
    }
}

public enum ArgumentOption : CustomStringConvertible {
    case Anything
    case NonOptional
    case Optional
    
    public var description: String {
        switch self {
        case .Anything:
            return "ArgumentOption.Anything"
        case .NonOptional:
            return "ArgumentOption.NonOptional"
        case .Optional:
            return "ArgumentOption.Optional"
        }
    }
}

public struct DidCallResult {
    public let success: Bool
    public let recordedCallsDescription: String
}

public enum DidCallResultIncludeOption : CustomStringConvertible {
    case Yes
    case No
    case OnlyOnSuccess
    case OnlyOnUnsuccess
    
    public var description: String {
        switch self {
        case .Yes:
            return "DidCallResultIncludeOption.Yes"
        case .No:
            return "DidCallResultIncludeOption.No"
        case .OnlyOnSuccess:
            return "DidCallResultIncludeOption.OnlyOnSuccess"
        case .OnlyOnUnsuccess:
            return "DidCallResultIncludeOption.OnlyOnUnsuccess"
        }
    }
}

public enum CountSpecifier {
    case Exactly(Int)
    case AtLeast(Int)
    case AtMost(Int)
}

public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var called = (functionList: [String](), argumentsList: [[Any]]())
    var called: (functionList: [String], argumentsList: [[Any]]) {get set}
    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, arguments: [Any])
    
    // Used if you want to reset the called function/arguments lists
    func clearRecordedLists()
    
    
    // For Internal Use ONLY
    func didCall(function function: String, withArgs arguments: Array<Any>, countSpecifier: CountSpecifier, recordedCallsDescOption: DidCallResultIncludeOption) -> DidCallResult
}

public extension CallRecorder {
    func recordCall(function function: String = __FUNCTION__, arguments: [Any] = [Any]()) {
        self.called.functionList.append(function)
        self.called.argumentsList.append(arguments)
    }
    
    func clearRecordedLists() {
        self.called.functionList = Array<String>()
        self.called.argumentsList = Array<Array<Any>>()
    }
    
    func didCall(function function: String, withArgs arguments: Array<Any> = [Any](), countSpecifier: CountSpecifier = .AtLeast(1), recordedCallsDescOption: DidCallResultIncludeOption) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
            case .Exactly(let count): success = timesCalled(function, arguments: arguments) == count
            case .AtLeast(let count): success = timesCalled(function, arguments: arguments) >= count
            case .AtMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }
        
        let recordedCallsDescription = self.descriptionOfRecordedCalls(wasSuccessful: success, returnOption: recordedCallsDescOption)
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }
    
    // MARK: Protocol Helper Functions
    
    private func timesCalled(function: String, arguments: Array<Any>) -> Int {
        return numberOfMatchingCalls(function: function, functions: self.called.functionList, argsList: arguments, argsLists: self.called.argumentsList)
    }
    
    private func descriptionOfRecordedCalls(wasSuccessful success: Bool, returnOption: DidCallResultIncludeOption) -> String {
        switch returnOption {
        case .Yes:
            return descriptionOfCalls(functionList: self.called.functionList, argumentsList: self.called.argumentsList)
        case .No:
            return ""
        case .OnlyOnSuccess:
            return success ? descriptionOfCalls(functionList: self.called.functionList, argumentsList: self.called.argumentsList) : ""
        case .OnlyOnUnsuccess:
            return !success ? descriptionOfCalls(functionList: self.called.functionList, argumentsList: self.called.argumentsList) : ""
        }
    }
}

// MARK: Helper Functions

private func numberOfMatchingCalls(function function: String, functions: Array<String>, argsList: Array<Any>, argsLists: Array<Array<Any>>) -> Int {
    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    guard argsList.count != 0 else {
        return functions.reduce(0) { $1 == function ? $0 + 1 : $0 }
    }
    
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
    return functionList.enumerate().map { $1 == functionName ? $0 : -1 }.filter { $0 != -1 }
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
        case .Anything:
            return true
        case .NonNil:
            return !isNil(recordedArg)
        case .Nil:
            return isNil(recordedArg)
        case .InstanceOf(let type):
            let cleanedType = "\(type)".replaceMatching(regex: "\\.Type+$", withString: "")
            let cleanedRecordedArgType = "\(recordedArg.dynamicType)"
            
            return cleanedType == cleanedRecordedArgType
        case .InstanceOfWith(let input):
            let isRecordedArgAnOptional = "\(recordedArg.dynamicType)".indexForMatching(regex: "^Optional<") != nil
            let passesOptionCheck = (input.option == ArgumentOption.Anything) ||
                                    (input.option == ArgumentOption.NonOptional && !isRecordedArgAnOptional) ||
                                    (input.option == ArgumentOption.Optional && isRecordedArgAnOptional)
            
            if !passesOptionCheck {
                return false
            }
            
            let cleanedType = "\(input.type)".replaceMatching(regex: "\\.Type+$", withString: "")
            let cleanedRecordedArgType = "\(recordedArg.dynamicType)".replaceMatching(regex: "^Optional<", withString: "")
                .replaceMatching(regex: ">+$", withString: "")
            
            return cleanedType == cleanedRecordedArgType
        case .KindOf(let type):
            if let recordedArgAsObject = recordedArg as? AnyObject {
                return recordedArgAsObject.isKindOfClass(type)
            }
            
            return false
        }
    } else {
        return passedArg.dynamicType == recordedArg.dynamicType && "\(passedArg)" == "\(recordedArg)"
    }
}

private func isNil(value: Any) -> Bool {
    // Currently best known way to check for nil (Swift doesn't allow -> 'Any' == 'nil')
    let isValueAnOptional = "\(value.dynamicType)".rangeOfString("^Optional<", options: .RegularExpressionSearch, range: nil, locale: nil) != nil
    
    return isValueAnOptional && "\(value)" == "nil"
}

private func descriptionOfCalls(functionList functionList: Array<String>, argumentsList: Array<Array<Any>>) -> String {
    if functionList.isEmpty {
        return "<>"
    }
    
    return zip(functionList, argumentsList).reduce("", combine: { (concatenatedString, element: (function: String, argumentList: Array<Any>)) -> String in
        var entry = element.function
        
        let parameterListStringRepresentation = element.argumentList.stringRepresentation()
        if !parameterListStringRepresentation.isEmpty {
            entry += " with " + parameterListStringRepresentation
        }
        entry = "<" + entry + ">"
        
        return concatenatedString.isEmpty ? entry : concatenatedString + ", " + entry
    })
}

// MARK: Private Extensions

private extension String {
    private func replaceMatching(regex regex: String, withString string: String) -> String {
        return self.stringByReplacingOccurrencesOfString(regex, withString: string, options: .RegularExpressionSearch, range: nil)
    }
    
    private func indexForMatching(regex regex: String) -> Range<Index>? {
        return self.rangeOfString(regex, options: .RegularExpressionSearch, range: nil, locale: nil)
    }
}

private extension Array {
    private func stringRepresentation() -> String {
        return self.map{ "\($0)" }.joinWithSeparator(", ")
    }
}
