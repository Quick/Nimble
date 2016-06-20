import Foundation

// In order to use GloballyEquatable, conform to Equatable
public protocol GloballyEquatable {
    func isEqualTo(other: GloballyEquatable) -> Bool
}

public extension GloballyEquatable where Self : Equatable {
    func isEqualTo(other: GloballyEquatable) -> Bool {
        if (self.dynamicType == other.dynamicType) {
            let selfMirror = Mirror(reflecting: self)
            let otherMirror = Mirror(reflecting: other)
            
            // HACK #1
            let bothAreOptionals = selfMirror.displayStyle == .Optional && otherMirror.displayStyle == .Optional
            if bothAreOptionals && selfMirror.children.first == nil && otherMirror.children.first == nil {
                print(selfMirror.children.first)
                print(otherMirror.children.first)
                return true
            }
            
            // HACK #2
            let atLeastOneIsOptional = selfMirror.displayStyle == .Optional || otherMirror.displayStyle == .Optional
            if !bothAreOptionals && atLeastOneIsOptional {
                return false
            }
            
            // HACK #1: if other is Optional<SameType>.None then if let will auto fail even if Self is Optional<SameType>
            // HACK #2: if let will auto unwrap other (of type Optional<SameType> even if Self is also Optional<SameType>
            // 'if let' seems to have been broken/redesigned since I've last worked on this
            if let other = other as? Self {
                return self == other
            }
        }
        
        return false
    }
}

public extension GloballyEquatable {
    func isEqualTo(other: GloballyEquatable) -> Bool {
        assertionFailure("type '\(Self.self)' does not conform to 'Equatable'")
        return false
    }
}


/* bug in Swift causes every enum WITHOUT an associated value's "description" to be the first declared
enum value WITHOUT an associated value's description
i.e. -> since ".Anything" is the first enum value then the default description for ".Anything",
".NonNil", and ".Nil" will all be "Anything" -> must override to fix issue by conforming to "CustomStringConvertible" 
    This is not reproducable in a Playground */

public enum Argument : CustomStringConvertible, GloballyEquatable {
    case Anything
    case NonNil
    case Nil
    case InstanceOf(type: Any.Type)
    case InstanceOfWith(type: Any.Type, option: ArgumentOption)
    case KindOf(type: AnyClass)
    
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

public enum ArgumentOption : CustomStringConvertible, GloballyEquatable {
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

public enum CountSpecifier {
    case Exactly(Int)
    case AtLeast(Int)
    case AtMost(Int)
}

public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var called = (functionList: [String](), argumentsList: [[GloballyEquatable]]())
    var called: (functionList: [String], argumentsList: [[GloballyEquatable]]) {get set}
    
    // **MUST** call in every method you want to spy
    func recordCall(function function: String, arguments: GloballyEquatable...)
    
    // Used if you want to reset the called function/arguments lists
    func clearRecordedLists()
    
    
    // For Internal Use ONLY
    func didCall(function function: String, withArguments arguments: Array<GloballyEquatable>, countSpecifier: CountSpecifier) -> DidCallResult
}

public extension CallRecorder {
    func recordCall(function function: String = #function, arguments: GloballyEquatable...) {
        self.called.functionList.append(function)
        self.called.argumentsList.append(arguments)
    }
    
    func clearRecordedLists() {
        self.called.functionList = Array<String>()
        self.called.argumentsList = Array<Array<GloballyEquatable>>()
    }
    
    func didCall(function function: String, withArguments arguments: Array<GloballyEquatable> = [GloballyEquatable](), countSpecifier: CountSpecifier = .AtLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
            case .Exactly(let count): success = timesCalled(function, arguments: arguments) == count
            case .AtLeast(let count): success = timesCalled(function, arguments: arguments) >= count
            case .AtMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }
        
        let recordedCallsDescription = descriptionOfCalls(functionList: self.called.functionList, argumentsList: self.called.argumentsList)
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }
    
    // MARK: Protocol Helper Functions
    
    private func timesCalled(function: String, arguments: Array<GloballyEquatable>) -> Int {
        return numberOfMatchingCalls(function: function, functions: self.called.functionList, argsList: arguments, argsLists: self.called.argumentsList)
    }
}

// MARK: Private Helper Functions

private func numberOfMatchingCalls(function function: String, functions: Array<String>, argsList: Array<GloballyEquatable>, argsLists: Array<Array<GloballyEquatable>>) -> Int {
    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    guard argsList.count != 0 else {
        return functions.reduce(0) { $1 == function ? $0 + 1 : $0 }
    }
    
    let potentialMatchIndexes = matchingIndexesFor(functionName: function, functionList: functions)
    var correctCallsCount = 0
    
    for index in potentialMatchIndexes {
        let recordedArgsList = argsLists[index]
        if isEqualArgsLists(passedArgs: argsList, recordedArgs: recordedArgsList) {
            correctCallsCount += 1
        }
    }
    
    return correctCallsCount
}

private func matchingIndexesFor(functionName functionName: String, functionList: Array<String>) -> [Int] {
    return functionList.enumerate().map { $1 == functionName ? $0 : -1 }.filter { $0 != -1 }
}

private func isEqualArgsLists(passedArgs passedArgs: Array<GloballyEquatable>, recordedArgs: Array<GloballyEquatable>) -> Bool {
    if passedArgs.count != recordedArgs.count {
        return false
    }
    
    for index in 0..<recordedArgs.count {
        let passedArg = passedArgs[index]
        let recordedArg = recordedArgs[index]
        
        if !isEqualArgs(passedArg: passedArg, recordedArg: recordedArg) {
            return false
        }
    }
    
    return true
}

private func isEqualArgs(passedArg passedArg: GloballyEquatable, recordedArg: GloballyEquatable) -> Bool {
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
            let isRecordedArgAnOptional = isOptional(recordedArg)
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
            if let recordedArgAsObject = recordedArg as? NSObject {
                return recordedArgAsObject.isKindOfClass(type)
            }
            
            assertionFailure("Arguments passed to .KindOf must inherit from NSObject. <\(recordedArg)> of type <\(recordedArg.dynamicType)> does NOT inherit from NSObject.")
            return false
        }
    } else {
        return passedArg.isEqualTo(recordedArg)
    }
}

private func isNil(value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    let hasAValue = mirror.children.first?.value != nil
    
    return mirror.displayStyle == .Optional && !hasAValue
}

private func isOptional(value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    
    return mirror.displayStyle == .Optional
}

private func descriptionOfCalls(functionList functionList: Array<String>, argumentsList: Array<Array<GloballyEquatable>>) -> String {
    if functionList.isEmpty {
        return "<>"
    }
    
    return zip(functionList, argumentsList).reduce("", combine: { (concatenatedString, element: (function: String, argumentList: Array<GloballyEquatable>)) -> String in
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
}

private extension Array {
    private func stringRepresentation() -> String {
        return self.map{ "\($0)" }.joinWithSeparator(", ")
    }
}
